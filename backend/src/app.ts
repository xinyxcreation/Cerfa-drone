import Fastify, { FastifyInstance } from "fastify";

import envPlugin from "./plugins/env.js";
import databasePlugin from "./plugins/database.js";
import corsPlugin from "./plugins/cors.js";
import helmetPlugin from "./plugins/helmet.js";
import jwtPlugin from "./plugins/jwt.js";
import swaggerPlugin from "./plugins/swagger.js";
import errorHandlerPlugin from "./plugins/errorHandler.js";
import multipartPlugin from "./plugins/multipart.js";

import routes from "./routes/index.js";

export async function buildApp(): Promise<FastifyInstance> {
  const app = Fastify({
    logger: true,
  });

  await app.register(envPlugin);

  await app.register(databasePlugin);

  await app.register(corsPlugin);

  await app.register(helmetPlugin);

  await app.register(jwtPlugin);

  await app.register(swaggerPlugin);

  await app.register(errorHandlerPlugin);

  await app.register(multipartPlugin);

  await app.register(routes);

  return app;
}
