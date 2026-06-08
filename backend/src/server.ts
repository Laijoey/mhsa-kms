import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

import { createApp } from './app';

const PORT = process.env.PORT || 3000;

const app = createApp();

app.listen(PORT, () => {
  console.log(`MHSA-KMS Backend listening on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Firebase Emulator: ${process.env.FIREBASE_EMULATOR === 'true' ? 'enabled' : 'disabled'}`);
});
