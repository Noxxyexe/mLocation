document.querySelector('.close-btn')?.addEventListener('click', function() {
    document.querySelector('.container').style.display = 'none';
    fetch('https://mLocation/close', { method: 'POST' });
});

window.addEventListener('message', function(event) {
    if (event.data && event.data.action === 'open') {
        document.querySelector('.container').style.display = 'flex';
        if (event.data.vehicles) {
            const list = document.querySelector('.vehicle-list');
            list.innerHTML = '';
            event.data.vehicles.forEach(vehicle => {
                list.innerHTML += `
                    <div class="vehicle-card">
                        <img src="img/${vehicle.model}.png" alt="Vehicle IMG" class="vehicle-img" />
                        <h2>${vehicle.label || vehicle.model}</h2>
                        <ul>
                            <li>Seats: ${vehicle.seats || "?"}</li>
                            <li>Speed: ${vehicle.speed || "?"}</li>
                            <li>Price: $${vehicle.price}</li>
                        </ul>
                        <button class="rent-btn" data-model="${vehicle.model}">Rent</button>
                    </div>
                `;
            });
            // Ré-attache les listeners rent-btn
            document.querySelectorAll('.rent-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    document.querySelector('.container').style.display = 'none';
                    const model = this.getAttribute('data-model');
                    fetch('https://mLocation/rent', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ model })
                    });
                });
            });
        }
    }
    if (event.data && event.data.action === 'close') {
        document.querySelector('.container').style.display = 'none';
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        document.querySelector('.container').style.display = 'none';
        fetch('https://mLocation/close', { method: 'POST' });
    }
});
