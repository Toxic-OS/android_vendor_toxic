for device in $(cat vendor/toxic/toxic-os-build-targets)
do
    add_lunch_combo toxic_$device-eng
    add_lunch_combo toxic_$device-user
    add_lunch_combo toxic_$device-userdebug
done
