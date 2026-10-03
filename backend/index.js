const http = require("http");
const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.POSTGRES_HOST || "localhost",
  port: Number(process.env.POSTGRES_PORT || 5432),
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});

const servidor = http.createServer(async (req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Content-Type", "application/json");

  if (req.url !== "/") {
    res.statusCode = 404;
    res.end(JSON.stringify({ error: "No encontrado" }));
    return;
  }

  try {
    const resultado = await pool.query("SELECT NOW() AS ahora");
    res.statusCode = 200;
    res.end(JSON.stringify({ resultado: resultado.rows[0].ahora }));
  } catch (error) {
    res.statusCode = 500;
    res.end(JSON.stringify({ error: error.message }));
  }
});

const puerto = Number(process.env.PORT || 3000);
servidor.listen(puerto, () => {
  console.log("API escuchando en el puerto " + puerto);
});
