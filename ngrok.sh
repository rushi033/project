# Kill any existing ngrok process
pkill -f ngrok

# Start ngrok fresh for Jenkins (port 8080)
ngrok http 8080
