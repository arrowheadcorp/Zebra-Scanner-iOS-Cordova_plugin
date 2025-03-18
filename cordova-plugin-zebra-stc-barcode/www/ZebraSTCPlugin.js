var exec = require('cordova/exec');
exports.generateSTCBarcode = function(success, error) {
    exec(success, error, 'ZebraSTCPlugin', 'generateSTCBarcode', []);
};