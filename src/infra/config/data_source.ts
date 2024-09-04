import { DataSource } from "typeorm";

export const AppDataSource = new DataSource({
  // Remember to install corresponding database driver packages.
  type: "mssql",
  host: "host",
  port: 1433,
  database: "database",
  username: "username",
  password: "password",
  // TODO: synchronize: true,
  // TODO: logging: true,
  entities: ["src/infra/persistence/relational/models/*_model.ts"],
  // TODO: subscribers: [],
  // TODO: migrations: [],
  options: {
    trustServerCertificate: true,
  },
});
