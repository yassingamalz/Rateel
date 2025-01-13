const fs = require('fs');
const path = require('path');

const adaptiveIconContent = `<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background>
        <color android:color="@android:color/transparent"/>
    </background>
    <foreground>
        <inset android:drawable="@mipmap/ic_launcher_foreground" android:inset="0%" />
    </foreground>
</adaptive-icon>`;

const iconPaths = [
  'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
  'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml'
];

function fixIcons() {
  iconPaths.forEach(iconPath => {
    const fullPath = path.join(process.cwd(), iconPath);
    fs.writeFileSync(fullPath, adaptiveIconContent, 'utf-8');
    console.log(`Updated ${iconPath}`);
  });
}

fixIcons();