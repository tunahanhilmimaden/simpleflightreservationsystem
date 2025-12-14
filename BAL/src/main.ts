import 'reflect-metadata'
import * as dotenv from 'dotenv'
dotenv.config()
import { NestFactory } from '@nestjs/core'
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger'
import { AppModule } from './modules/app.module'

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true })
  app.setGlobalPrefix('api')

  const config = new DocumentBuilder()
    .setTitle('SkyRes Business Layer')
    .setDescription('AirportServicesDB mikroservisleri')
    .setVersion('1.0.0')
    .build()
  const document = SwaggerModule.createDocument(app, config)
  SwaggerModule.setup('docs', app, document)

  const port = process.env.PORT ? parseInt(process.env.PORT, 10) : 4000
  await app.listen(port)
  // eslint-disable-next-line no-console
  console.log(`BAL listening on http://localhost:${port} (Swagger: /docs)`)
}

bootstrap()
