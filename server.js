const express = require('express');
const pool = require('./db');
const path = require('path');

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// ===================== HOTEL CHAINS =====================

app.get('/api/chains', async (req, res) => {
  const { rows } = await pool.query(
    `SELECT c.*,
       (SELECT array_agg(email) FROM hc_email WHERE chain_id=c.chain_id) AS emails,
       (SELECT array_agg(phone_num) FROM hc_phone WHERE chain_id=c.chain_id) AS phones
     FROM hotel_chain c ORDER BY c.name`
  );
  res.json(rows);
});

app.post('/api/chains', async (req, res) => {
  const { name, address, emails, phones } = req.body;
  try {
    const { rows } = await pool.query(
      'INSERT INTO hotel_chain (name, address) VALUES ($1,$2) RETURNING *',
      [name, address]
    );
    const chain = rows[0];
    if (emails) for (const e of emails)
      await pool.query('INSERT INTO hc_email (chain_id,email) VALUES ($1,$2)', [chain.chain_id, e]);
    if (phones) for (const p of phones)
      await pool.query('INSERT INTO hc_phone (chain_id,phone_num) VALUES ($1,$2)', [chain.chain_id, p]);
    res.json(chain);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.put('/api/chains/:id', async (req, res) => {
  const { name, address } = req.body;
  try {
    const { rows } = await pool.query(
      'UPDATE hotel_chain SET name=$1, address=$2 WHERE chain_id=$3 RETURNING *',
      [name, address, req.params.id]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.delete('/api/chains/:id', async (req, res) => {
  await pool.query('DELETE FROM hotel_chain WHERE chain_id=$1', [req.params.id]);
  res.json({ ok: true });
});

// ===================== HOTELS =====================

app.get('/api/hotels', async (req, res) => {
  const { rows } = await pool.query(
    `SELECT h.*, hc.name AS chain_name,
       (SELECT array_agg(email) FROM h_email WHERE hotel_id=h.hotel_id) AS emails,
       (SELECT array_agg(phone_num) FROM h_phone WHERE hotel_id=h.hotel_id) AS phones
     FROM hotel h
     JOIN hotel_chain hc ON h.chain_id=hc.chain_id
     ORDER BY hc.name, h.city`
  );
  res.json(rows);
});

app.post('/api/hotels', async (req, res) => {
  const { chain_id, address, city, stars, emails, phones } = req.body;
  try {
    const { rows } = await pool.query(
      'INSERT INTO hotel (chain_id,address,city,stars) VALUES ($1,$2,$3,$4) RETURNING *',
      [chain_id, address, city, stars]
    );
    const hotel = rows[0];
    if (emails) for (const e of emails)
      await pool.query('INSERT INTO h_email (hotel_id,email) VALUES ($1,$2)', [hotel.hotel_id, e]);
    if (phones) for (const p of phones)
      await pool.query('INSERT INTO h_phone (hotel_id,phone_num) VALUES ($1,$2)', [hotel.hotel_id, p]);
    res.json(hotel);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.put('/api/hotels/:id', async (req, res) => {
  const { chain_id, address, city, stars } = req.body;
  try {
    const { rows } = await pool.query(
      'UPDATE hotel SET chain_id=$1, address=$2, city=$3, stars=$4 WHERE hotel_id=$5 RETURNING *',
      [chain_id, address, city, stars, req.params.id]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.delete('/api/hotels/:id', async (req, res) => {
  await pool.query('DELETE FROM hotel WHERE hotel_id=$1', [req.params.id]);
  res.json({ ok: true });
});

// ===================== ROOMS =====================

app.get('/api/rooms', async (req, res) => {
  const hotelId = req.query.hotel_id;
  let q = `SELECT r.*, h.address AS hotel_address, h.city, h.stars, hc.name AS chain_name,
             (SELECT array_agg(amenity) FROM room_amenity WHERE room_id=r.room_id) AS amenities,
             (SELECT array_agg(problem_desc) FROM room_problem WHERE room_id=r.room_id) AS problems
           FROM room r
           JOIN hotel h ON r.hotel_id=h.hotel_id
           JOIN hotel_chain hc ON h.chain_id=hc.chain_id`;
  const params = [];
  if (hotelId) { q += ' WHERE r.hotel_id=$1'; params.push(hotelId); }
  q += ' ORDER BY r.hotel_id, r.room_id';
  const { rows } = await pool.query(q, params);
  res.json(rows);
});

app.post('/api/rooms', async (req, res) => {
  const { hotel_id, price, capacity, extendable_by, view_type, amenities } = req.body;
  try {
    const { rows } = await pool.query(
      `INSERT INTO room (hotel_id,price,capacity,extendable_by,view_type)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [hotel_id, price, capacity, extendable_by || 0, view_type || 'none']
    );
    const room = rows[0];
    if (amenities) for (const a of amenities)
      await pool.query('INSERT INTO room_amenity (room_id,amenity) VALUES ($1,$2)', [room.room_id, a]);
    res.json(room);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.put('/api/rooms/:id', async (req, res) => {
  const { price, capacity, extendable_by, view_type } = req.body;
  try {
    const { rows } = await pool.query(
      `UPDATE room SET price=$1, capacity=$2, extendable_by=$3, view_type=$4
       WHERE room_id=$5 RETURNING *`,
      [price, capacity, extendable_by, view_type, req.params.id]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.delete('/api/rooms/:id', async (req, res) => {
  await pool.query('DELETE FROM room WHERE room_id=$1', [req.params.id]);
  res.json({ ok: true });
});

// ===================== ROOM SEARCH (availability) =====================

app.get('/api/rooms/search', async (req, res) => {
  const { startDate, endDate, capacity, city, chainId, stars, maxPrice, minRooms } = req.query;

  if (!startDate || !endDate) return res.status(400).json({ error: 'startDate and endDate required' });

  let q = `
    SELECT r.room_id, r.price, r.capacity, r.extendable_by, r.view_type,
           h.hotel_id, h.address AS hotel_address, h.city, h.stars, h.num_rooms,
           hc.chain_id, hc.name AS chain_name,
           (SELECT array_agg(amenity) FROM room_amenity WHERE room_id=r.room_id) AS amenities
    FROM room r
    JOIN hotel h ON r.hotel_id = h.hotel_id
    JOIN hotel_chain hc ON h.chain_id = hc.chain_id
    WHERE r.room_id NOT IN (
        SELECT b.room_id FROM booking b
        WHERE b.is_active = TRUE
          AND b.start_date < $2 AND b.end_date > $1
    )
    AND r.room_id NOT IN (
        SELECT rt.room_id FROM renting rt
        WHERE rt.is_active = TRUE
          AND rt.start_date < $2 AND rt.end_date > $1
    )`;

  const params = [startDate, endDate];
  let idx = 3;

  if (capacity)  { q += ` AND r.capacity >= $${idx}`; params.push(capacity); idx++; }
  if (city)      { q += ` AND h.city = $${idx}`;      params.push(city);     idx++; }
  if (chainId)   { q += ` AND hc.chain_id = $${idx}`; params.push(chainId);  idx++; }
  if (stars)     { q += ` AND h.stars = $${idx}`;     params.push(stars);    idx++; }
  if (maxPrice)  { q += ` AND r.price <= $${idx}`;    params.push(maxPrice); idx++; }
  if (minRooms)  { q += ` AND h.num_rooms >= $${idx}`; params.push(minRooms); idx++; }

  q += ' ORDER BY r.price';

  try {
    const { rows } = await pool.query(q, params);
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ===================== CUSTOMERS =====================

app.get('/api/customers', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM customer ORDER BY full_name');
  res.json(rows);
});

app.post('/api/customers', async (req, res) => {
  const { full_name, address, id_type, id_number } = req.body;
  try {
    const { rows } = await pool.query(
      `INSERT INTO customer (full_name,address,id_type,id_number)
       VALUES ($1,$2,$3,$4) RETURNING *`,
      [full_name, address, id_type, id_number]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.put('/api/customers/:id', async (req, res) => {
  const { full_name, address, id_type, id_number } = req.body;
  try {
    const { rows } = await pool.query(
      `UPDATE customer SET full_name=$1, address=$2, id_type=$3, id_number=$4
       WHERE customer_id=$5 RETURNING *`,
      [full_name, address, id_type, id_number, req.params.id]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.delete('/api/customers/:id', async (req, res) => {
  await pool.query('DELETE FROM customer WHERE customer_id=$1', [req.params.id]);
  res.json({ ok: true });
});

// ===================== EMPLOYEES =====================

app.get('/api/employees', async (req, res) => {
  const { rows } = await pool.query(
    `SELECT e.*, h.address AS hotel_address, h.city, hc.name AS chain_name
     FROM employee e
     JOIN hotel h ON e.hotel_id=h.hotel_id
     JOIN hotel_chain hc ON h.chain_id=hc.chain_id
     ORDER BY e.full_name`
  );
  res.json(rows);
});

app.post('/api/employees', async (req, res) => {
  const { full_name, address, ssn, hotel_id, role } = req.body;
  try {
    const { rows } = await pool.query(
      `INSERT INTO employee (full_name,address,ssn,hotel_id,role)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [full_name, address, ssn, hotel_id, role]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.put('/api/employees/:id', async (req, res) => {
  const { full_name, address, ssn, hotel_id, role } = req.body;
  try {
    const { rows } = await pool.query(
      `UPDATE employee SET full_name=$1, address=$2, ssn=$3, hotel_id=$4, role=$5
       WHERE employee_id=$6 RETURNING *`,
      [full_name, address, ssn, hotel_id, role, req.params.id]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.delete('/api/employees/:id', async (req, res) => {
  await pool.query('DELETE FROM employee WHERE employee_id=$1', [req.params.id]);
  res.json({ ok: true });
});

// ===================== BOOKINGS =====================

app.get('/api/bookings', async (req, res) => {
  const { rows } = await pool.query(
    `SELECT b.*, c.full_name AS customer_name,
            h.address AS hotel_address, h.city, hc.name AS chain_name, r.capacity, r.price
     FROM booking b
     JOIN customer c ON b.customer_id=c.customer_id
     JOIN room r ON b.room_id=r.room_id
     JOIN hotel h ON r.hotel_id=h.hotel_id
     JOIN hotel_chain hc ON h.chain_id=hc.chain_id
     WHERE b.is_active = TRUE
     ORDER BY b.start_date`
  );
  res.json(rows);
});

app.post('/api/bookings', async (req, res) => {
  const { customer_id, room_id, start_date, end_date } = req.body;
  try {
    // Check for overlapping bookings/rentings
    const overlap = await pool.query(
      `SELECT 1 FROM booking WHERE room_id=$1 AND is_active=TRUE AND start_date < $3 AND end_date > $2
       UNION ALL
       SELECT 1 FROM renting WHERE room_id=$1 AND is_active=TRUE AND start_date < $3 AND end_date > $2`,
      [room_id, start_date, end_date]
    );
    if (overlap.rows.length > 0) return res.status(400).json({ error: 'Room not available for those dates' });

    const { rows } = await pool.query(
      `INSERT INTO booking (customer_id,room_id,start_date,end_date)
       VALUES ($1,$2,$3,$4) RETURNING *`,
      [customer_id, room_id, start_date, end_date]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.delete('/api/bookings/:id', async (req, res) => {
  await pool.query('DELETE FROM booking WHERE booking_id=$1', [req.params.id]);
  res.json({ ok: true });
});

// ===================== CHECK-IN (booking → renting) =====================

app.post('/api/bookings/:id/checkin', async (req, res) => {
  const { employee_id } = req.body;
  try {
    const bk = await pool.query('SELECT * FROM booking WHERE booking_id=$1 AND is_active=TRUE', [req.params.id]);
    if (bk.rows.length === 0) return res.status(404).json({ error: 'Booking not found or inactive' });

    const b = bk.rows[0];
    // Deactivate the booking
    await pool.query('UPDATE booking SET is_active=FALSE WHERE booking_id=$1', [b.booking_id]);

    // Create renting from booking
    const { rows } = await pool.query(
      `INSERT INTO renting (booking_id,customer_id,room_id,employee_id,start_date,end_date)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [b.booking_id, b.customer_id, b.room_id, employee_id, b.start_date, b.end_date]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

// ===================== RENTINGS =====================

app.get('/api/rentings', async (req, res) => {
  const { rows } = await pool.query(
    `SELECT rt.*, c.full_name AS customer_name, e.full_name AS employee_name,
            h.address AS hotel_address, h.city, hc.name AS chain_name, r.capacity, r.price
     FROM renting rt
     JOIN customer c ON rt.customer_id=c.customer_id
     JOIN room r ON rt.room_id=r.room_id
     JOIN hotel h ON r.hotel_id=h.hotel_id
     JOIN hotel_chain hc ON h.chain_id=hc.chain_id
     JOIN employee e ON rt.employee_id=e.employee_id
     WHERE rt.is_active = TRUE
     ORDER BY rt.start_date`
  );
  res.json(rows);
});

app.post('/api/rentings', async (req, res) => {
  const { customer_id, room_id, employee_id, start_date, end_date } = req.body;
  try {
    const overlap = await pool.query(
      `SELECT 1 FROM booking WHERE room_id=$1 AND is_active=TRUE AND start_date < $3 AND end_date > $2
       UNION ALL
       SELECT 1 FROM renting WHERE room_id=$1 AND is_active=TRUE AND start_date < $3 AND end_date > $2`,
      [room_id, start_date, end_date]
    );
    if (overlap.rows.length > 0) return res.status(400).json({ error: 'Room not available for those dates' });

    const { rows } = await pool.query(
      `INSERT INTO renting (customer_id,room_id,employee_id,start_date,end_date)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [customer_id, room_id, employee_id, start_date, end_date]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

app.delete('/api/rentings/:id', async (req, res) => {
  await pool.query('DELETE FROM renting WHERE renting_id=$1', [req.params.id]);
  res.json({ ok: true });
});

// ===================== PAYMENTS =====================

app.get('/api/payments', async (req, res) => {
  const { rows } = await pool.query(
    `SELECT p.*, c.full_name AS customer_name
     FROM payment p
     JOIN renting rt ON p.renting_id=rt.renting_id
     JOIN customer c ON rt.customer_id=c.customer_id
     ORDER BY p.payment_date DESC`
  );
  res.json(rows);
});

app.post('/api/payments', async (req, res) => {
  const { renting_id, amount } = req.body;
  try {
    const { rows } = await pool.query(
      'INSERT INTO payment (renting_id,amount) VALUES ($1,$2) RETURNING *',
      [renting_id, amount]
    );
    res.json(rows[0]);
  } catch (err) { res.status(400).json({ error: err.message }); }
});

// ===================== VIEWS =====================

app.get('/api/views/available-per-area', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM available_rooms_per_area');
  res.json(rows);
});

app.get('/api/views/hotel-capacity', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM hotel_aggregated_capacity');
  res.json(rows);
});

// ===================== ARCHIVES =====================

app.get('/api/archives/bookings', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM booking_archive ORDER BY archived_date DESC');
  res.json(rows);
});

app.get('/api/archives/rentings', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM renting_archive ORDER BY archived_date DESC');
  res.json(rows);
});

// ===================== HELPER: distinct cities =====================

app.get('/api/cities', async (req, res) => {
  const { rows } = await pool.query('SELECT DISTINCT city FROM hotel ORDER BY city');
  res.json(rows.map(r => r.city));
});

// ===================== START =====================

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`e-Hotels server running on http://localhost:${PORT}`));
