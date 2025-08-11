(() => {
  var __defProp = Object.defineProperty;
  var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

  // cloudflare-auth-worker.js
  addEventListener("fetch", (event) => {
    event.respondWith(handleRequest(event.request));
  });
  async function handleRequest(request) {
    const { pathname } = new URL(request.url);
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type"
    };
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }
    switch (pathname) {
      case "/auth/signup":
        return handleSignup(request, corsHeaders);
      case "/auth/login":
        return handleLogin(request, corsHeaders);
      default:
        return new Response("Not Found", { status: 404 });
    }
  }
  __name(handleRequest, "handleRequest");
  async function handleSignup(request, headers) {
    try {
      const { email, password, userId, username } = await request.json();
      if (!email || !password || !username) {
        return new Response(JSON.stringify({ error: "Missing required fields" }), {
          status: 400,
          headers: { "Content-Type": "application/json", ...headers }
        });
      }
      const existingUser = await AUTH_STORE.get(email);
      if (existingUser) {
        return new Response(JSON.stringify({ error: "User already exists" }), {
          status: 409,
          headers: { "Content-Type": "application/json", ...headers }
        });
      }
      await AUTH_STORE.put(email, JSON.stringify({
        userId,
        email,
        password,
        username
      }));
      return new Response(JSON.stringify({
        userId,
        username,
        message: "Account created successfully"
      }), {
        status: 201,
        headers: { "Content-Type": "application/json", ...headers }
      });
    } catch (err) {
      return new Response(JSON.stringify({ error: err.message }), {
        status: 500,
        headers: { "Content-Type": "application/json", ...headers }
      });
    }
  }
  __name(handleSignup, "handleSignup");
  async function handleLogin(request, headers) {
    try {
      const { email, password } = await request.json();
      if (!email || !password) {
        return new Response(JSON.stringify({ error: "Missing email or password" }), {
          status: 400,
          headers: { "Content-Type": "application/json", ...headers }
        });
      }
      const userData = await AUTH_STORE.get(email);
      if (!userData) {
        return new Response(JSON.stringify({ error: "User not found" }), {
          status: 404,
          headers: { "Content-Type": "application/json", ...headers }
        });
      }
      const user = JSON.parse(userData);
      if (user.password !== password) {
        return new Response(JSON.stringify({ error: "Invalid credentials" }), {
          status: 401,
          headers: { "Content-Type": "application/json", ...headers }
        });
      }
      return new Response(JSON.stringify({
        userId: user.userId,
        email: user.email,
        username: user.username
      }), {
        headers: { "Content-Type": "application/json", ...headers }
      });
    } catch (err) {
      return new Response(JSON.stringify({ error: err.message }), {
        status: 500,
        headers: { "Content-Type": "application/json", ...headers }
      });
    }
  }
  __name(handleLogin, "handleLogin");
})();
//# sourceMappingURL=cloudflare-auth-worker.js.map
