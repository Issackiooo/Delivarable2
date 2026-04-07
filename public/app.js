// ==================== TAB NAVIGATION ====================
document.querySelectorAll('.tab').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tab').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById('tab-' + btn.dataset.tab).classList.add('active');
    loadTabData(btn.dataset.tab);
  });
});

function loadTabData(tab) {
  const loaders = {
    search: loadSearchDropdowns,
    bookings: loadBookings,
    rentings: loadRentings,
    payments: loadPayments,
    customers: loadCustomers,
    employees: loadEmployees,
    hotels: loadHotels,
    rooms: loadRooms,
    chains: loadChains,
    views: loadViews,
    archives: loadArchives,
  };
  if (loaders[tab]) loaders[tab]();
}

// ==================== HELPERS ====================
async function api(url, opts) {
  const res = await fetch(url, opts);
  const data = await res.json();
  if (!res.ok) { alert(data.error || 'Error'); throw new Error(data.error); }
  return data;
}

function post(url, body) {
  return api(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
}
function put(url, body) {
  return api(url, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
}
function del(url) {
  return api(url, { method: 'DELETE' });
}

function formData(formId) {
  const fd = new FormData(document.getElementById(formId));
  const obj = {};
  for (const [k, v] of fd.entries()) if (v !== '') obj[k] = v;
  return obj;
}

function resetForm(formId) {
  document.getElementById(formId).reset();
  const hidden = document.querySelector(`#${formId} input[type="hidden"]`);
  if (hidden) hidden.value = '';
}

function fmtDate(d) { return d ? d.substring(0, 10) : ''; }

// ==================== POPULATE DROPDOWNS ====================
async function populateChainsDropdown(selectors) {
  const chains = await api('/api/chains');
  selectors.forEach(sel => {
    const el = document.querySelector(sel);
    if (!el) return;
    const val = el.value;
    el.innerHTML = '<option value="">Any</option>';
    chains.forEach(c => el.innerHTML += `<option value="${c.chain_id}">${c.name}</option>`);
    if (val) el.value = val;
  });
}

async function populateHotelsDropdown(selectors) {
  const hotels = await api('/api/hotels');
  selectors.forEach(sel => {
    const el = document.querySelector(sel);
    if (!el) return;
    const val = el.value;
    el.innerHTML = '';
    hotels.forEach(h => el.innerHTML += `<option value="${h.hotel_id}">${h.chain_name} - ${h.address}, ${h.city} (${h.stars}★)</option>`);
    if (val) el.value = val;
  });
}

async function populateCustomersDropdown(selectors) {
  const customers = await api('/api/customers');
  selectors.forEach(sel => {
    const el = document.querySelector(sel);
    if (!el) return;
    el.innerHTML = '';
    customers.forEach(c => el.innerHTML += `<option value="${c.customer_id}">${c.full_name}</option>`);
  });
}

async function populateEmployeesDropdown(selectors) {
  const employees = await api('/api/employees');
  selectors.forEach(sel => {
    const el = document.querySelector(sel);
    if (!el) return;
    el.innerHTML = '';
    employees.forEach(e => el.innerHTML += `<option value="${e.employee_id}">${e.full_name} (${e.chain_name} - ${e.city})</option>`);
  });
}

// ==================== SEARCH ====================
let searchDropdownsLoaded = false;
async function loadSearchDropdowns() {
  if (searchDropdownsLoaded) return;
  searchDropdownsLoaded = true;

  const cities = await api('/api/cities');
  const citySelect = document.querySelector('#search-form select[name="city"]');
  cities.forEach(c => citySelect.innerHTML += `<option value="${c}">${c}</option>`);

  await populateChainsDropdown(['#search-form select[name="chainId"]']);
}

document.getElementById('search-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const d = formData('search-form');
  const params = new URLSearchParams(d).toString();
  const rooms = await api('/api/rooms/search?' + params);
  const role = document.getElementById('role-select').value;
  const tbody = document.querySelector('#search-results tbody');
  tbody.innerHTML = '';
  if (rooms.length === 0) { tbody.innerHTML = '<tr><td colspan="11">No rooms found</td></tr>'; return; }
  rooms.forEach(r => {
    const amenities = r.amenities ? r.amenities.join(', ') : '';
    let action = '';
    if (role === 'customer') {
      action = `<button class="btn-sm btn-primary" onclick="bookRoom(${r.room_id})">Book</button>`;
    } else {
      action = `<button class="btn-sm btn-primary" onclick="rentRoom(${r.room_id})">Rent</button>`;
    }
    tbody.innerHTML += `<tr>
      <td>${r.room_id}</td><td>${r.chain_name}</td><td>${r.hotel_address}</td><td>${r.city}</td>
      <td>${r.stars}★</td><td>${r.capacity}</td><td>$${r.price}</td><td>${r.view_type}</td>
      <td>${r.extendable_by}</td><td>${amenities}</td><td>${action}</td>
    </tr>`;
  });
});

async function bookRoom(roomId) {
  const customerId = prompt('Enter your Customer ID:');
  if (!customerId) return;
  const startDate = document.querySelector('#search-form input[name="startDate"]').value;
  const endDate = document.querySelector('#search-form input[name="endDate"]').value;
  await post('/api/bookings', { customer_id: customerId, room_id: roomId, start_date: startDate, end_date: endDate });
  alert('Booking created!');
  document.getElementById('search-form').dispatchEvent(new Event('submit'));
}

async function rentRoom(roomId) {
  const customerId = prompt('Enter Customer ID:');
  if (!customerId) return;
  const employeeId = prompt('Enter Employee ID:');
  if (!employeeId) return;
  const startDate = document.querySelector('#search-form input[name="startDate"]').value;
  const endDate = document.querySelector('#search-form input[name="endDate"]').value;
  await post('/api/rentings', { customer_id: customerId, room_id: roomId, employee_id: employeeId, start_date: startDate, end_date: endDate });
  alert('Renting created!');
  document.getElementById('search-form').dispatchEvent(new Event('submit'));
}

// ==================== BOOKINGS ====================
async function loadBookings() {
  const bookings = await api('/api/bookings');
  const role = document.getElementById('role-select').value;
  const tbody = document.querySelector('#bookings-table tbody');
  tbody.innerHTML = '';
  bookings.forEach(b => {
    let actions = `<button class="btn-sm btn-danger" onclick="deleteBooking(${b.booking_id})">Cancel</button>`;
    if (role === 'employee') {
      actions += ` <button class="btn-sm btn-primary" onclick="checkinBooking(${b.booking_id})">Check-in</button>`;
    }
    tbody.innerHTML += `<tr>
      <td>${b.booking_id}</td><td>${b.customer_name}</td><td>${b.chain_name}</td>
      <td>${b.hotel_address}</td><td>${b.city}</td><td>${b.room_id}</td><td>${b.capacity}</td>
      <td>${fmtDate(b.start_date)}</td><td>${fmtDate(b.end_date)}</td><td>${actions}</td>
    </tr>`;
  });
}

async function deleteBooking(id) {
  if (!confirm('Cancel this booking?')) return;
  await del('/api/bookings/' + id);
  loadBookings();
}

async function checkinBooking(id) {
  const employeeId = prompt('Enter Employee ID for check-in:');
  if (!employeeId) return;
  await post('/api/bookings/' + id + '/checkin', { employee_id: employeeId });
  alert('Checked in! Booking converted to renting.');
  loadBookings();
}

// ==================== RENTINGS ====================
async function loadRentings() {
  await populateCustomersDropdown(['#renting-form select[name="customer_id"]']);
  await populateEmployeesDropdown(['#renting-form select[name="employee_id"]']);

  const rentings = await api('/api/rentings');
  const tbody = document.querySelector('#rentings-table tbody');
  tbody.innerHTML = '';
  rentings.forEach(r => {
    tbody.innerHTML += `<tr>
      <td>${r.renting_id}</td><td>${r.customer_name}</td><td>${r.employee_name}</td>
      <td>${r.chain_name}</td><td>${r.hotel_address}, ${r.city}</td>
      <td>${r.room_id}</td><td>${fmtDate(r.start_date)}</td><td>${fmtDate(r.end_date)}</td>
      <td><button class="btn-sm btn-danger" onclick="deleteRenting(${r.renting_id})">Delete</button></td>
    </tr>`;
  });
}

document.getElementById('renting-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  await post('/api/rentings', formData('renting-form'));
  alert('Renting created!');
  resetForm('renting-form');
  loadRentings();
});

async function deleteRenting(id) {
  if (!confirm('Delete this renting?')) return;
  await del('/api/rentings/' + id);
  loadRentings();
}

// ==================== PAYMENTS ====================
async function loadPayments() {
  const payments = await api('/api/payments');
  const tbody = document.querySelector('#payments-table tbody');
  tbody.innerHTML = '';
  payments.forEach(p => {
    tbody.innerHTML += `<tr>
      <td>${p.payment_id}</td><td>${p.renting_id}</td><td>${p.customer_name}</td>
      <td>$${p.amount}</td><td>${fmtDate(p.payment_date)}</td>
    </tr>`;
  });
}

document.getElementById('payment-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  await post('/api/payments', formData('payment-form'));
  alert('Payment recorded!');
  resetForm('payment-form');
  loadPayments();
});

// ==================== CUSTOMERS CRUD ====================
async function loadCustomers() {
  const customers = await api('/api/customers');
  const tbody = document.querySelector('#customers-table tbody');
  tbody.innerHTML = '';
  customers.forEach(c => {
    tbody.innerHTML += `<tr>
      <td>${c.customer_id}</td><td>${c.full_name}</td><td>${c.address}</td>
      <td>${c.id_type}</td><td>${c.id_number}</td><td>${fmtDate(c.registration_date)}</td>
      <td>
        <button class="btn-sm btn-primary" onclick='editCustomer(${JSON.stringify(c)})'>Edit</button>
        <button class="btn-sm btn-danger" onclick="deleteCustomer(${c.customer_id})">Delete</button>
      </td>
    </tr>`;
  });
}

document.getElementById('customer-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const d = formData('customer-form');
  if (d.customer_id) {
    await put('/api/customers/' + d.customer_id, d);
  } else {
    await post('/api/customers', d);
  }
  resetForm('customer-form');
  loadCustomers();
});

function editCustomer(c) {
  const f = document.getElementById('customer-form');
  f.customer_id.value = c.customer_id;
  f.full_name.value = c.full_name;
  f.address.value = c.address;
  f.id_type.value = c.id_type;
  f.id_number.value = c.id_number;
}

async function deleteCustomer(id) {
  if (!confirm('Delete this customer?')) return;
  await del('/api/customers/' + id);
  loadCustomers();
}

// ==================== EMPLOYEES CRUD ====================
async function loadEmployees() {
  await populateHotelsDropdown(['#employee-form select[name="hotel_id"]']);

  const employees = await api('/api/employees');
  const tbody = document.querySelector('#employees-table tbody');
  tbody.innerHTML = '';
  employees.forEach(e => {
    tbody.innerHTML += `<tr>
      <td>${e.employee_id}</td><td>${e.full_name}</td><td>${e.address}</td>
      <td>${e.ssn}</td><td>${e.chain_name} - ${e.hotel_address}, ${e.city}</td><td>${e.role}</td>
      <td>
        <button class="btn-sm btn-primary" onclick='editEmployee(${JSON.stringify(e)})'>Edit</button>
        <button class="btn-sm btn-danger" onclick="deleteEmployee(${e.employee_id})">Delete</button>
      </td>
    </tr>`;
  });
}

document.getElementById('employee-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const d = formData('employee-form');
  if (d.employee_id) {
    await put('/api/employees/' + d.employee_id, d);
  } else {
    await post('/api/employees', d);
  }
  resetForm('employee-form');
  loadEmployees();
});

function editEmployee(e) {
  const f = document.getElementById('employee-form');
  f.employee_id.value = e.employee_id;
  f.full_name.value = e.full_name;
  f.address.value = e.address;
  f.ssn.value = e.ssn;
  f.hotel_id.value = e.hotel_id;
  f.role.value = e.role;
}

async function deleteEmployee(id) {
  if (!confirm('Delete this employee?')) return;
  await del('/api/employees/' + id);
  loadEmployees();
}

// ==================== HOTELS CRUD ====================
async function loadHotels() {
  await populateChainsDropdown(['#hotel-form select[name="chain_id"]']);

  const hotels = await api('/api/hotels');
  const tbody = document.querySelector('#hotels-table tbody');
  tbody.innerHTML = '';
  hotels.forEach(h => {
    tbody.innerHTML += `<tr>
      <td>${h.hotel_id}</td><td>${h.chain_name}</td><td>${h.address}</td><td>${h.city}</td>
      <td>${h.stars}★</td><td>${h.num_rooms}</td>
      <td>
        <button class="btn-sm btn-primary" onclick='editHotel(${JSON.stringify(h)})'>Edit</button>
        <button class="btn-sm btn-danger" onclick="deleteHotel(${h.hotel_id})">Delete</button>
      </td>
    </tr>`;
  });
}

document.getElementById('hotel-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const d = formData('hotel-form');
  if (d.hotel_id) {
    await put('/api/hotels/' + d.hotel_id, d);
  } else {
    await post('/api/hotels', d);
  }
  resetForm('hotel-form');
  loadHotels();
});

function editHotel(h) {
  const f = document.getElementById('hotel-form');
  f.hotel_id.value = h.hotel_id;
  f.chain_id.value = h.chain_id;
  f.address.value = h.address;
  f.city.value = h.city;
  f.stars.value = h.stars;
}

async function deleteHotel(id) {
  if (!confirm('Delete this hotel and all its rooms?')) return;
  await del('/api/hotels/' + id);
  loadHotels();
}

// ==================== ROOMS CRUD ====================
async function loadRooms() {
  await populateHotelsDropdown(['#room-form select[name="hotel_id"]']);

  const rooms = await api('/api/rooms');
  const tbody = document.querySelector('#rooms-table tbody');
  tbody.innerHTML = '';
  rooms.forEach(r => {
    const amenities = r.amenities ? r.amenities.join(', ') : '';
    tbody.innerHTML += `<tr>
      <td>${r.room_id}</td><td>${r.chain_name} - ${r.hotel_address}</td><td>${r.city}</td>
      <td>$${r.price}</td><td>${r.capacity}</td><td>${r.extendable_by}</td>
      <td>${r.view_type}</td><td>${r.is_available ? 'Yes' : 'No'}</td><td>${amenities}</td>
      <td>
        <button class="btn-sm btn-primary" onclick='editRoom(${JSON.stringify(r)})'>Edit</button>
        <button class="btn-sm btn-danger" onclick="deleteRoom(${r.room_id})">Delete</button>
      </td>
    </tr>`;
  });
}

document.getElementById('room-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const d = formData('room-form');
  if (d.room_id) {
    await put('/api/rooms/' + d.room_id, d);
  } else {
    await post('/api/rooms', d);
  }
  resetForm('room-form');
  loadRooms();
});

function editRoom(r) {
  const f = document.getElementById('room-form');
  f.room_id.value = r.room_id;
  f.hotel_id.value = r.hotel_id;
  f.price.value = r.price;
  f.capacity.value = r.capacity;
  f.extendable_by.value = r.extendable_by;
  f.view_type.value = r.view_type;
}

async function deleteRoom(id) {
  if (!confirm('Delete this room?')) return;
  await del('/api/rooms/' + id);
  loadRooms();
}

// ==================== CHAINS CRUD ====================
async function loadChains() {
  const chains = await api('/api/chains');
  const tbody = document.querySelector('#chains-table tbody');
  tbody.innerHTML = '';
  chains.forEach(c => {
    tbody.innerHTML += `<tr>
      <td>${c.chain_id}</td><td>${c.name}</td><td>${c.address}</td><td>${c.num_hotels}</td>
      <td>${(c.emails || []).join(', ')}</td><td>${(c.phones || []).join(', ')}</td>
      <td>
        <button class="btn-sm btn-primary" onclick='editChain(${JSON.stringify(c)})'>Edit</button>
        <button class="btn-sm btn-danger" onclick="deleteChain(${c.chain_id})">Delete</button>
      </td>
    </tr>`;
  });
}

document.getElementById('chain-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const d = formData('chain-form');
  if (d.chain_id) {
    await put('/api/chains/' + d.chain_id, d);
  } else {
    await post('/api/chains', d);
  }
  resetForm('chain-form');
  loadChains();
});

function editChain(c) {
  const f = document.getElementById('chain-form');
  f.chain_id.value = c.chain_id;
  f.name.value = c.name;
  f.address.value = c.address;
}

async function deleteChain(id) {
  if (!confirm('Delete this chain and ALL its hotels/rooms?')) return;
  await del('/api/chains/' + id);
  loadChains();
}

// ==================== VIEWS ====================
async function loadViews() {
  const v1 = await api('/api/views/available-per-area');
  const tbody1 = document.querySelector('#view1-table tbody');
  tbody1.innerHTML = '';
  v1.forEach(r => {
    tbody1.innerHTML += `<tr><td>${r.area}</td><td>${r.available_rooms}</td></tr>`;
  });

  const v2 = await api('/api/views/hotel-capacity');
  const tbody2 = document.querySelector('#view2-table tbody');
  tbody2.innerHTML = '';
  v2.forEach(r => {
    tbody2.innerHTML += `<tr>
      <td>${r.chain_name}</td><td>${r.hotel_address}</td><td>${r.city}</td>
      <td>${r.stars}★</td><td>${r.total_rooms}</td><td>${r.total_capacity}</td>
    </tr>`;
  });
}

// ==================== ARCHIVES ====================
async function loadArchives() {
  const ba = await api('/api/archives/bookings');
  const tbody1 = document.querySelector('#booking-archives-table tbody');
  tbody1.innerHTML = '';
  ba.forEach(r => {
    tbody1.innerHTML += `<tr>
      <td>${r.archive_id}</td><td>${r.booking_id}</td><td>${r.customer_name || ''}</td>
      <td>${r.room_id || ''}</td><td>${r.hotel_address || ''}</td><td>${r.chain_name || ''}</td>
      <td>${fmtDate(r.start_date)}</td><td>${fmtDate(r.end_date)}</td><td>${fmtDate(r.archived_date)}</td>
    </tr>`;
  });

  const ra = await api('/api/archives/rentings');
  const tbody2 = document.querySelector('#renting-archives-table tbody');
  tbody2.innerHTML = '';
  ra.forEach(r => {
    tbody2.innerHTML += `<tr>
      <td>${r.archive_id}</td><td>${r.renting_id}</td><td>${r.customer_name || ''}</td>
      <td>${r.room_id || ''}</td><td>${r.hotel_address || ''}</td><td>${r.chain_name || ''}</td>
      <td>${r.employee_name || ''}</td><td>${fmtDate(r.start_date)}</td><td>${fmtDate(r.end_date)}</td>
      <td>${fmtDate(r.archived_date)}</td>
    </tr>`;
  });
}

// ==================== INIT ====================
loadSearchDropdowns();
