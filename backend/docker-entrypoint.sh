#!/bin/sh
set -e

# Patch db.config.js to use MONGO_URL env var if provided
MONGO_URL="${MONGO_URL:-mongodb://localhost:27017/dd_db}"

cat > /app/app/config/db.config.js <<EOF
module.exports = {
  url: "${MONGO_URL}"
};
EOF

# Patch server.js to enable CORS with allowed origin from env
CORS_ORIGIN="${CORS_ORIGIN:-http://localhost}"

cat > /app/server.js <<'SERVEREOF'
const express = require("express");
const cors    = require("cors");

const app = express();

app.use(cors({
  origin: process.env.CORS_ORIGIN || "*"
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const db = require("./app/models");
db.mongoose
  .connect(db.url, {
    useNewUrlParser: true,
    useUnifiedTopology: true
  })
  .then(() => {
    console.log("Connected to the database!");
  })
  .catch(err => {
    console.log("Cannot connect to the database!", err);
    process.exit();
  });

app.get("/", (req, res) => {
  res.json({ message: "Welcome to DD Task application." });
});

require("./app/routes/turorial.routes")(app);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}.`);
});
SERVEREOF

exec "$@"
