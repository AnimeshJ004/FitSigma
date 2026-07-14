<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class UpdateAdminCredentials extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        $merchant = \App\Models\Merchant::first();
        if ($merchant) {
            $merchant->username = 'test@gmail.com';
            $merchant->email = 'test@gmail.com';
            $merchant->password = \Illuminate\Support\Facades\Hash::make('test123');
            $merchant->save();
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        $merchant = \App\Models\Merchant::where('email', 'test@gmail.com')->first();
        if ($merchant) {
            $merchant->username = 'admin';
            $merchant->email = 'admin@froiden.com';
            $merchant->password = \Illuminate\Support\Facades\Hash::make('123456');
            $merchant->save();
        }
    }
}
