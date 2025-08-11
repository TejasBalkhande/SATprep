addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

const API_KEY = 'QAZWSXEDCRFVTGB';
const allowedOrigins = [
  'http://localhost:*',
  'https://*.tejasbalkhande221.workers.dev'
];

async function handleRequest(request) {
  const origin = request.headers.get('origin');
  const isAllowed = allowedOrigins.some(o => new RegExp(o).test(origin));

  const corsHeaders = {
    'Access-Control-Allow-Origin': isAllowed ? origin : '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Credentials': 'true'
  };

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  const { pathname } = new URL(request.url);
  console.log(`Request: ${request.method} ${pathname}`);

  try {
    if (pathname === '/api/blog') {
      return await handleBlogList(request, corsHeaders);
    } else if (pathname.startsWith('/api/blog/')) {
      const slug = pathname.split('/')[3];
      if (!slug) {
        return new Response(JSON.stringify({ error: 'Slug is required' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }
      return await handleBlogPost(request, slug, corsHeaders);
    } else if (pathname === '/sitemap.xml') {
      return await generateSitemap(request, corsHeaders);
    } else {
      return new Response(JSON.stringify({
        error: 'Not found',
        path: pathname,
        availableEndpoints: ['/api/blog', '/api/blog/{slug}', '/sitemap.xml']
      }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }
  } catch (err) {
    console.error(`Handler error: ${err.message}`);
    console.error(`Stack trace: ${err.stack}`);
    return new Response(JSON.stringify({
      error: 'Internal Server Error',
      message: err.message
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }
}

async function handleBlogList(request, headers) {
  try {
    console.log('Handling blog list request...');

    if (typeof BLOG_STORE === 'undefined') {
      console.error('BLOG_STORE KV namespace is not available');
      return new Response(JSON.stringify({
        error: 'Blog store not configured',
        message: 'The blog storage system is not properly configured'
      }), {
        status: 500,
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    }

    if (request.method === 'GET') {
      const keys = await BLOG_STORE.list({ prefix: 'post:' });
      console.log(`Found ${keys.keys.length} blog post keys`);

      const posts = [];

      for (const key of keys.keys) {
        try {
          console.log(`Processing key: ${key.name}`);
          const post = await BLOG_STORE.get(key.name, 'json');
          if (post) {
            const { content, ...summary } = post;
            const postSummary = {
              title: summary.title || 'Untitled',
              slug: summary.slug || key.name.replace('post:', ''),
              metaDescription: summary.metaDescription || 'No description available',
              metaKeywords: summary.metaKeywords || [],
              coverImageUrl: summary.coverImageUrl || '',
              author: summary.author || 'Unknown',
              datePublished: summary.datePublished || new Date().toISOString(),
              lastUpdated: summary.lastUpdated || null,
              ...summary
            };
            posts.push(postSummary);
            console.log(`Added post: ${postSummary.title}`);
          }
        } catch (err) {
          console.error(`Error processing ${key.name}: ${err.message}`);
        }
      }

      posts.sort((a, b) => {
        const dateA = new Date(a.datePublished);
        const dateB = new Date(b.datePublished);
        return dateB.getTime() - dateA.getTime();
      });

      console.log(`Returning ${posts.length} blog posts`);
      return new Response(JSON.stringify(posts), {
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    } else if (request.method === 'POST') {
      const authHeader = request.headers.get('Authorization');
      if (authHeader !== API_KEY) {
        console.log('Unauthorized request - invalid API key');
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
          status: 401,
          headers: { ...headers, 'Content-Type': 'application/json' }
        });
      }

      const postData = await request.json();

      if (!postData.slug) {
        return new Response(JSON.stringify({
          error: 'Missing slug',
          message: 'Slug is required for creating a new post'
        }), {
          status: 400,
          headers: { ...headers, 'Content-Type': 'application/json' }
        });
      }

      if (!postData.title || !postData.content) {
        return new Response(JSON.stringify({
          error: 'Missing required fields',
          message: 'Title and content are required'
        }), {
          status: 400,
          headers: { ...headers, 'Content-Type': 'application/json' }
        });
      }

      const existing = await BLOG_STORE.get(`post:${postData.slug}`, 'json');
      if (existing) {
        return new Response(JSON.stringify({
          error: 'Post already exists',
          message: 'A post with this slug already exists'
        }), {
          status: 409,
          headers: { ...headers, 'Content-Type': 'application/json' }
        });
      }

      const newPost = {
        title: postData.title,
        slug: postData.slug,
        metaDescription: postData.metaDescription || '',
        metaKeywords: postData.metaKeywords || [],
        coverImageUrl: postData.coverImageUrl || '',
        author: postData.author || 'Unknown',
        content: postData.content,
        datePublished: new Date().toISOString(),
        lastUpdated: null
      };

      await BLOG_STORE.put(`post:${postData.slug}`, JSON.stringify(newPost));
      console.log(`Created new post: ${newPost.title}`);

      return new Response(JSON.stringify({
        success: true,
        slug: newPost.slug,
        message: 'Post created successfully'
      }), {
        status: 201,
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    } else {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    }
  } catch (err) {
    console.error(`Blog list error: ${err.message}`);
    console.error(`Stack trace: ${err.stack}`);
    return new Response(JSON.stringify({
      error: 'Failed to retrieve blog posts',
      message: 'An error occurred while fetching blog posts',
      details: err.message
    }), {
      status: 500,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }
}

async function handleBlogPost(request, slug, headers) {
  try {
    console.log(`Handling blog post request for slug: ${slug}`);

    if (typeof BLOG_STORE === 'undefined') {
      console.error('BLOG_STORE KV namespace is not available');
      return new Response(JSON.stringify({
        error: 'Blog store not configured',
        message: 'The blog storage system is not properly configured'
      }), {
        status: 500,
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    }

    if (request.method === 'GET') {
      const post = await BLOG_STORE.get(`post:${slug}`, 'json');
      if (!post) {
        console.log(`Post not found for slug: ${slug}`);
        return new Response(JSON.stringify({
          error: 'Post not found',
          slug: slug
        }), {
          status: 404,
          headers: { ...headers, 'Content-Type': 'application/json' }
        });
      }

      const fullPost = {
        title: post.title || 'Untitled',
        slug: post.slug || slug,
        metaDescription: post.metaDescription || 'No description available',
        metaKeywords: post.metaKeywords || [],
        coverImageUrl: post.coverImageUrl || '',
        author: post.author || 'Unknown',
        content: post.content || '',
        datePublished: post.datePublished || new Date().toISOString(),
        lastUpdated: post.lastUpdated || null,
        ...post
      };

      console.log(`Returning post: ${fullPost.title}`);
      return new Response(JSON.stringify(fullPost), {
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    }

    const authHeader = request.headers.get('Authorization');
    if (authHeader !== API_KEY) {
      console.log('Unauthorized request - invalid API key');
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    }

    if (request.method === 'PUT') {
      const postData = await request.json();

      if (!postData.title || !postData.content) {
        return new Response(JSON.stringify({
          error: 'Missing required fields',
          message: 'Title and content are required'
        }), {
          status: 400,
          headers: { ...headers, 'Content-Type': 'application/json' }
        });
      }

      const existingPost = await BLOG_STORE.get(`post:${slug}`, 'json');

      const updatedPost = {
        title: postData.title,
        slug: slug,
        metaDescription: postData.metaDescription || '',
        metaKeywords: postData.metaKeywords || [],
        coverImageUrl: postData.coverImageUrl || '',
        author: postData.author || 'Unknown',
        content: postData.content,
        datePublished: existingPost?.datePublished || postData.datePublished || new Date().toISOString(),
        lastUpdated: new Date().toISOString()
      };

      await BLOG_STORE.put(`post:${slug}`, JSON.stringify(updatedPost));
      console.log(`Updated post: ${updatedPost.title}`);

      return new Response(JSON.stringify({
        success: true,
        message: 'Post updated successfully'
      }), {
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    } else if (request.method === 'DELETE') {
      const existingPost = await BLOG_STORE.get(`post:${slug}`, 'json');
      if (!existingPost) {
        return new Response(JSON.stringify({
          error: 'Post not found',
          slug: slug
        }), {
          status: 404,
          headers: { ...headers, 'Content-Type': 'application/json' }
        });
      }

      await BLOG_STORE.delete(`post:${slug}`);
      console.log(`Deleted post with slug: ${slug}`);

      return new Response(JSON.stringify({
        success: true,
        message: 'Post deleted successfully'
      }), {
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    } else {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: { ...headers, 'Content-Type': 'application/json' }
      });
    }
  } catch (err) {
    console.error(`Blog post error: ${err.message}`);
    console.error(`Stack trace: ${err.stack}`);
    return new Response(JSON.stringify({
      error: 'Failed to process blog post',
      message: 'An error occurred while processing the blog post',
      details: err.message
    }), {
      status: 500,
      headers: { ...headers, 'Content-Type': 'application/json' }
    });
  }
}

async function generateSitemap(request, headers) {
  try {
    console.log('Generating sitemap...');

    if (typeof BLOG_STORE === 'undefined') {
      console.error('BLOG_STORE KV namespace is not available');
      return new Response('Sitemap generation failed: Blog store not configured', {
        status: 500,
        headers
      });
    }

    const baseUrl = 'https://tejasbalkhande221.workers.dev';
    let xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>${baseUrl}</loc>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>${baseUrl}/blog</loc>
    <changefreq>daily</changefreq>
    <priority>0.8</priority>
  </url>`;

    const keys = await BLOG_STORE.list({ prefix: 'post:' });
    console.log(`Adding ${keys.keys.length} posts to sitemap`);

    for (const key of keys.keys) {
      try {
        const post = await BLOG_STORE.get(key.name, 'json');
        if (post && post.slug) {
          const lastmod = post.lastUpdated || post.datePublished || new Date().toISOString();
          xml += `
  <url>
    <loc>${baseUrl}/blog/${post.slug}</loc>
    <lastmod>${lastmod.split('T')[0]}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.7</priority>
  </url>`;
        }
      } catch (err) {
        console.error(`Sitemap entry error for ${key.name}: ${err.message}`);
      }
    }

    xml += '\n</urlset>';

    return new Response(xml, {
      headers: {
        ...headers,
        'Content-Type': 'application/xml'
      }
    });
  } catch (err) {
    console.error(`Sitemap generation error: ${err.message}`);
    console.error(`Stack trace: ${err.stack}`);
    return new Response(`Sitemap generation failed: ${err.message}`, {
      status: 500,
      headers
    });
  }
}

async function createTestPost() {
  const testPost = {
    title: 'Welcome to Our Blog',
    slug: 'welcome-to-our-blog',
    metaDescription: 'This is our first blog post to test the system.',
    metaKeywords: ['welcome', 'blog', 'test'],
    coverImageUrl: 'https://via.placeholder.com/600x300',
    author: 'Admin',
    content: '<h1>Welcome!</h1><p>This is a test blog post to ensure everything is working correctly.</p>',
    datePublished: new Date().toISOString(),
    lastUpdated: null
  };

  try {
    await BLOG_STORE.put(`post:${testPost.slug}`, JSON.stringify(testPost));
    console.log('Test post created successfully');
  } catch (err) {
    console.error('Failed to create test post:', err.message);
  }
}

createTestPost();