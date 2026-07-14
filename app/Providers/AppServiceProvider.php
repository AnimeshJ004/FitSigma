<?php

namespace App\Providers;

use Carbon\Carbon;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Schema::defaultStringLength(191);

        try {
            if (config('database.default') === 'sqlite' && DB::connection() instanceof \Illuminate\Database\SQLiteConnection) {
                DB::connection()->getPdo()->sqliteCreateFunction('MONTH', function ($date) {
                return date('m', strtotime($date));
            }, 1);
            DB::connection()->getPdo()->sqliteCreateFunction('YEAR', function ($date) {
                return date('Y', strtotime($date));
            }, 1);
            DB::connection()->getPdo()->sqliteCreateFunction('DAY', function ($date) {
                return date('d', strtotime($date));
            }, 1);
            DB::connection()->getPdo()->sqliteCreateFunction('DATE', function ($date) {
                return date('Y-m-d', strtotime($date));
            }, 1);
            DB::connection()->getPdo()->sqliteCreateFunction('MONTHNAME', function ($date) {
                return date('F', strtotime($date));
            }, 1);
            DB::connection()->getPdo()->sqliteCreateFunction('DATE_FORMAT', function ($date, $format) {
                $replacements = [
                    '%d' => 'd', '%m' => 'm', '%M' => 'F', '%b' => 'M',
                    '%y' => 'y', '%Y' => 'Y', '%h' => 'h', '%H' => 'H',
                    '%i' => 'i', '%s' => 's', '%a' => 'A', '%p' => 'A'
                ];
                $phpFormat = str_replace(array_keys($replacements), array_values($replacements), $format);
                return date($phpFormat, strtotime($date));
            }, 2);
            }
        } catch (\Exception $e) {
            // Ignore database connection errors during build/optimization
        }
        Validator::extend('alpha_spaces_num', function($attribute, $value)
        {
            return preg_match('/(^[A-Za-z0-9 ]+$)+/', $value);
        });


        Validator::extend('alpha_spaces', function($attribute, $value)
        {
            return preg_match('/(^[A-Za-z ]+$)+/', $value);
        });

        Validator::extend('alpha_spaces_num_spcl', function($attribute, $value)
        {
            return preg_match('/(^[A-Za-z0-9()\/\&<>:., ]+$)+/', $value);
        });

        Validator::extend('num_length', function($attribute, $value, $parameters, $validator)
        {
            // return strlen($value) == $parameters[0];
            $validator->addReplacer('num_length', function($message, $attribute, $rule, $parameters){
                return str_replace([':length'], $parameters, $message);
            });

            return strlen($value) == $parameters[0];
        });

        //Validation for date isn't past today
        Validator::extend('date_check', function($attribute, $value)
        {
            $deadline = Carbon::createFromFormat('m/d/Y', $value)->format('Y-m-d');

            if($deadline <= Carbon::now()->format('Y-m-d')) {
                return false;
            }

            return true;
        });
    }

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }
}
