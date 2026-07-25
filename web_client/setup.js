const fs = require('fs');
fs.writeFileSync('.env', 'DATABASE_URL="file:./dev.db"\nNEXTAUTH_SECRET="my-super-secret-key-for-local-dev"\nNEXTAUTH_URL="http://localhost:3000"\n', 'utf8');
console.log('.env file created successfully.');
