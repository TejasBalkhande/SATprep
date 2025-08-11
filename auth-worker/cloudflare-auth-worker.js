// Cloudflare Worker - Enhanced auth handler with KV
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
}

async function handleRequest(request) {
  const { pathname } = new URL(request.url)
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  }

  // Handle CORS preflight
  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  // Route requests
  switch(pathname) {
    case '/auth/signup':
      return handleSignup(request, corsHeaders)
    case '/auth/login':
      return handleLogin(request, corsHeaders)
    default:
      return new Response('Not Found', { status: 404 })
  }
}

async function handleSignup(request, headers) {
  try {
    const { email, password, userId, username } = await request.json()

    // Validate input
    if (!email || !password || !username) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', ...headers }
      })
    }

    // Check if user exists
    const existingUser = await AUTH_STORE.get(email)
    if (existingUser) {
      return new Response(JSON.stringify({ error: 'User already exists' }), {
        status: 409,
        headers: { 'Content-Type': 'application/json', ...headers }
      })
    }

    // Store user
    await AUTH_STORE.put(email, JSON.stringify({
      userId,
      email,
      password,
      username
    }))

    return new Response(JSON.stringify({
      userId,
      username,
      message: 'Account created successfully'
    }), {
      status: 201,
      headers: { 'Content-Type': 'application/json', ...headers }
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', ...headers }
    })
  }
}

async function handleLogin(request, headers) {
  try {
    const { email, password } = await request.json()

    // Validate input
    if (!email || !password) {
      return new Response(JSON.stringify({ error: 'Missing email or password' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', ...headers }
      })
    }

    const userData = await AUTH_STORE.get(email)

    if (!userData) {
      return new Response(JSON.stringify({ error: 'User not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json', ...headers }
      })
    }

    const user = JSON.parse(userData)
    if (user.password !== password) {
      return new Response(JSON.stringify({ error: 'Invalid credentials' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json', ...headers }
      })
    }

    return new Response(JSON.stringify({
      userId: user.userId,
      email: user.email,
      username: user.username
    }), {
      headers: { 'Content-Type': 'application/json', ...headers }
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', ...headers }
    })
  }
}
