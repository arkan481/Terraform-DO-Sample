const mongoose = require("mongoose");

const connectDB = async () => {
  let MONGO_URI;
  let options = {};

  if (process.env.NODE_ENV === "production") {
    MONGO_URI = process.env.MONGO_URI_PRODUCTION;
    options = {
      useNewUrlParser: true,
      useCreateIndex: true,
      useFindAndModify: false,
      useUnifiedTopology: true,
      ssl: true,
      tls: true,
      tlsCAFile: process.env.MONGO_CA_CERT_PATH,
    };
  } else {
    MONGO_URI = process.env.MONGO_URI_DEVELOPMENT;
    options = {
      useNewUrlParser: true,
      useCreateIndex: true,
      useFindAndModify: false,
      useUnifiedTopology: true,
    };
  }

  const conn = await mongoose.connect(MONGO_URI, options);

  console.log(
    `MongoDB Connected: ${conn.connection.host}`.cyan.underline.italic.bold
  );
};

module.exports = connectDB;
