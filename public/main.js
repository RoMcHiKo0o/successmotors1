function validateForm() {
    
    let errorInfo = [true, ''];
    message = document.getElementById('message');
    message.innerHTML = '';
    errorInfo = validateText(errorInfo);
    errorInfo = validateEmail(errorInfo);
    errorInfo = validatePhone(errorInfo);
    if (!errorInfo[0]) {
        message.innerHTML = errorInfo[1];
    }
    else {
        const captcha = grecaptcha.getResponse();
        if (captcha.length==0) {
            message.innerHTML = "Captcha не пройдена";
            errorInfo[0] = false;
        }
        // else {
        //     if (!newLeadQ(document.forms['webtolead']['email'].value.trim())) {
        //         message.innerHTML = "такой Lead уже существует";
        //         errorInfo[0] = false;
        //     }
        // }
    }
    return errorInfo[0];
        
}


function validateText(info) {
    if (info[0]) {
        form = document.forms['webtolead'];
        flag = (form['company'].value.trim().length > 0); // company check
        flag &&= (form['first_name'].value.trim().length > 0); // first name check
        flag &&= (form['last_name'].value.trim().length > 0); // last name check
        if (flag) {
            return info;
        }
        else {
            return [false, 'форма заполнена неправильно'];
        }
    }
    else {
        return info;
    }
}

function validateEmail(info) {
    if (info[0]) {
        flag = true;
        if (flag) {
            return info;
        }
        else {
            return [false, 'форма заполнена неправильно'];
        }
    }
    else {
        return info;
    }
}

function validatePhone(info) {
    if (info[0]) {
        flag=true;
        phone = document.forms['webtolead']['phone'].value.trim();
        patt = /^(\+)?(\([\d]+\))?([\d]+)$/g;
        flag = phone.match(patt)!==null;
        flag &&= (phone.length>0);
        if (flag) {
            return info;
        }
        else {
            return [false, 'форма заполнена неправильно'];
        }
    }
    else {
        return info;
    }
}

// function newLeadQ(email) {
//     {!REQUIRESCRIPT("/soap/ajax/57.0/connection.js")} 
//     var query = "SELECT Id FROM Lead WHERE Email = '" + email + "'";
//     console.log(123)
//     var result = sforce.connection.query(query);
//     var records = result.getArray("records");
//     return (records.length==0);
//   }