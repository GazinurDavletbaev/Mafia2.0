#!/bin/bash
flutter clean && \
flutter pub get && \
flutter build web --release && \
scp -r build/web/* root@161.104.46.234:/var/www/mafia_help_web/ && \
ssh root@161.104.46.234 "systemctl reload nginx" && \
echo "✅ Готово! http://161.104.46.234/"