/**
 * Copyright © 2015 Magento. All rights reserved.
 * See COPYING.txt for license details.
 */
define([
    'Magento_Paypal/js/rules/payflow/bml/disable'
], function (disable) {
    'use strict';

    return function ($target, $owner, data) {
        if ($target.find(data.enableButton).val() === '0') {
            disable($target, $owner, data);
        }
    };
});
