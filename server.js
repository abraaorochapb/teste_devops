const express = require("express");
const cors = require("cors");
const app = express();

app.use(cors());

app.get("/", async (req, res) => {
  try {
    res.json({ message: "Api Teste" });
  } catch (err) {
    res.status(500).json({
      error: "Erro interno 🚨"
    });
  }
});

const PORT = 80;
app.listen(PORT, () => console.log(`Backend rodando na porta ${PORT}`));