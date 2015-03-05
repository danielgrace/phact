/*global $:false */

$(function(){
    "use strict";
    var method  = $('#method'),
        realm   = $('#realm'),
        deviceGroup = $('.device-group'),
        openUdid = $('.open-udid');

    var setMethodSettings = function(methodInfo) {
        var methodParams    = methodInfo.split('-'),
            data            = methodsMap[methodParams[0]][methodParams[1]],
            paramsWrapper   = $('#params'),
            paramList       = paramsWrapper.find('ul');

        realm.val(realms[data.type]);

        $('#method-name').val(methodParams[1]);

        if (data.type === 0) {
            deviceGroup.show();
            openUdid.hide();
            deviceGroup.find('input').attr('disabled', false);
            openUdid.find('input').attr('disabled', true);
            setDeviceSettings($('input[name="device"]:checked').attr('id'));
        } else {
            deviceGroup.hide();
            openUdid.show();
            deviceGroup.find('input').attr('disabled', true);
            openUdid.find('input').attr('disabled', false);
            //setDeviceSettings(null);
        }

        paramList.empty();

        if (data.params !== undefined) {
            var paramHTML   = '',
                param      = null;

            paramsWrapper.show();

            $.each(data.params, function(idx){
                param = data.params[idx];

                paramHTML += '<li>';
                paramHTML += '<label for="params-' + param.name + '">' + param.name + '</label>';
//                console.log(param.type);
                switch (param.type) {
                    case null:
                        paramHTML += '<textarea  name="params[' + param.name + ']" ' +
                            ' id="params-' + param.name + '" value="" />';
                        break;
                    case 'object':
                    case 'array':
                        paramHTML += '<textarea name="params[' + param.name + ']" id="params-' + param.name + '"></textarea>';
                        break;
                }

                paramHTML += '</li>';
            });

            paramList.append(paramHTML);
        } else {
            paramsWrapper.hide();
        }
    };

    var renderMethodsMap = function () {
        var html = '',
            cssStyle  = '',
            methodInfo = {};

        $.each(methodsMap, function(idx) {
            methodInfo = methodsMap[idx];

            $.each(methodInfo, function(idx1) {
                cssStyle = (methodInfo[idx1].type === 1) ? ' style="color: red"' : '';
                html += '<option value="' + idx + '-' + idx1 + '"' + cssStyle + '>' + idx1 + '</option>';
            });
        });

        method.append(html);
    };

    var renderDeviceMap = function() {
        var html = '',
            radioGroup = $('.radio-group');

        $.each(deviceMap, function(idx) {
            var username = deviceMap[idx].username;

            html += '<li>';
            html += '<input type="radio" id="' + username + '" name="device">';
            html += '<label for="' + username + '">' + username + '</label>';
            html += '</li>';
        });

        radioGroup.append(html);
        radioGroup.find('input').first().attr('checked', true);

        $('input[name="device"]').click(function(){
            setDeviceSettings($(this).attr('id'));
        });
    };

    var setDeviceSettings = function(id) {
        var settings        = deviceMap[id],
            deviceControls  = $('#auth-info input[id="username"],#auth-info input[id="password"]');

        if (id === null) {
            deviceControls.val('');
        } else {
            deviceControls.each(function(){
                $(this).val(settings[$(this).attr('id')]);
            });
        }
    };


    method.change(function(){
        setMethodSettings($(this).val());
    });

    $('#generate-request-form').submit(function(){
        var data = $(this).serialize();

        $.ajax({
            type: 'POST',
            url: '',
            dataType: 'json',
            data: data,
            success: function(res) {
                var request = res.request,
                    response = res.response,
                    str = '',
                    pad = [],
                    padSize = 30,
                    i = padSize,
                    crlf = "\r\n\r\n";

                if (window.JSON && window.JSON.parse) {
                    console.log(res.response);
                    request = JSON.stringify(JSON.parse(res.request), undefined, 2);

                    if (response !== null) {

                        response = JSON.stringify(JSON.parse(res.response), undefined, 2);
                    } else {
                        response = '';
                    }
                }

                for (i; i--;) {
                    pad[i] = '=';
                }

                pad = pad.join('');

                str += pad + " JSON-RPC Response " + pad + crlf;
                str += response + crlf;
                str += pad + " JSON-RPC Request =" + pad + crlf;
                str += request + crlf;
                str += pad + " HTTP Response ====" + pad + crlf;
                str += res.responseHeader + crlf;
                str += pad + " HTTP Request =====" + pad + crlf;
                str += res.requestHeader + crlf;


                $('#info').val(str);
            }
        });

        return false;
    });

    renderMethodsMap();
    renderDeviceMap();
    setMethodSettings(method.val());
    setDeviceSettings($('input[name="device"]:checked').attr('id'));
});