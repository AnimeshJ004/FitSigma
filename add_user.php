<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Merchant;
use Illuminate\Support\Facades\Hash;

$merchant = Merchant::first();
if ($merchant) {
    $merchant->username = 'test@gmail.com';
    $merchant->email = 'test@gmail.com';
    $merchant->password = Hash::make('test123');
    $merchant->save();
    echo "Updated existing user to test@gmail.com / test123\n";
} else {
    echo "No merchant found!\n";
}
