document.getElementById('loginForm').addEventListener('submit', function(event) {
    event.preventDefault();
    
    const username = document.getElementById('username').value;
    const email = document.getElementById('email').value;
    const bio = document.getElementById('bio').value;

    // Hide login form and show welcome message
    document.getElementById('login-container').style.display = 'none';
    document.getElementById('welcome-container').style.display = 'block';
    
    // Display a welcome message with the username
    document.getElementById('userMessage').innerText = `Welcome, ${username}!`;
    
    // Store user details for the account view
    document.getElementById('accountUsername').innerText = username;
    document.getElementById('accountEmail').innerText = email;
    document.getElementById('accountBio').innerText = bio;
});

document.getElementById('viewAccountBtn').addEventListener('click', function() {
    document.getElementById('welcome-container').style.display = 'none';
    document.getElementById('account-container').style.display = 'block';
});

document.getElementById('logoutBtn').addEventListener('click', function() {
    // Reset to initial view
    document.getElementById('account-container').style.display = 'none';
    document.getElementById('login-container').style.display = 'block';
    document.getElementById('loginForm').reset();
});
