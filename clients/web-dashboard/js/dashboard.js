// Dashboard functionality

const api = new VPSApi('http://your-server:8069', 'your-api-key');
let resourceChart;

// Initialize dashboard
async function initDashboard() {
    await updateResourceChart();
    await updateUserTable();
    setInterval(updateResourceChart, 30000);
    setInterval(updateUserTable, 60000);
}

// Update resource chart
async function updateResourceChart() {
    const resources = await api.getMonitorResources();
    
    const data = {
        labels: ['CPU', 'Memory', 'Disk'],
        datasets: [{
            data: [
                resources.cpu.usage,
                resources.memory.percentage,
                resources.disk.percentage
            ],
            backgroundColor: [
                'rgba(255, 99, 132, 0.5)',
                'rgba(54, 162, 235, 0.5)',
                'rgba(255, 206, 86, 0.5)'
            ]
        }]
    };

    if (!resourceChart) {
        const ctx = document.getElementById('resourceChart').getContext('2d');
        resourceChart = new Chart(ctx, {
            type: 'bar',
            data: data,
            options: {
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });
    } else {
        resourceChart.data = data;
        resourceChart.update();
    }
}

// Update user table
async function updateUserTable() {
    const bandwidth = await api.getMonitorBandwidth();
    const logins = await api.getMonitorLogins();
    
    const table = document.getElementById('userTable');
    table.innerHTML = '';
    
    for (const [username, data] of Object.entries(bandwidth)) {
        const row = table.insertRow();
        row.innerHTML = `
            <td>${username}</td>
            <td>${data.type || '-'}</td>
            <td>${data.status || 'Active'}</td>
            <td>${data.quota_used}/${data.quota_limit} GB</td>
            <td>
                <button class="btn btn-sm btn-danger" onclick="deleteUser('${username}')">Delete</button>
                <button class="btn btn-sm btn-warning" onclick="toggleLock('${username}')">Lock</button>
            </td>
        `;
    }
}

// Add user
async function addUser() {
    const form = document.getElementById('addUserForm');
    const data = Object.fromEntries(new FormData(form));
    
    try {
        await api.createUser(data);
        bootstrap.Modal.getInstance(document.getElementById('addUserModal')).hide();
        await updateUserTable();
    } catch (error) {
        alert('Error creating user: ' + error.message);
    }
}

// Delete user
async function deleteUser(username) {
    if (confirm(`Delete user ${username}?`)) {
        try {
            await api.deleteUser(username);
            await updateUserTable();
        } catch (error) {
            alert('Error deleting user: ' + error.message);
        }
    }
}

// Toggle user lock
async function toggleLock(username) {
    try {
        const status = await api.getUserStatus(username);
        if (status.status === 'locked') {
            await api.unlockUser(username);
        } else {
            await api.lockUser(username);
        }
        await updateUserTable();
    } catch (error) {
        alert('Error toggling lock: ' + error.message);
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', initDashboard); 