var mails = {};
var $maillist = '';

$(document).ready(function() {
    $('#mailcontainer').draggable();
});

window.addEventListener('message', function(event) {
    const data = event.data;
    if(data.type == 'read') {
        document.querySelector('#email').innerHTML = data.mail.sender;
        document.querySelector('#subject').innerHTML = '<p>' + data.mail.subject  + '</p>';
        var converter = new showdown.Converter(),
        text = data.mail.mail,
        mail = converter.makeHtml(text);
        document.querySelector('#mailtext').innerHTML = mail;
        $("#writemail").fadeOut(0);
        $("#mailcontainer").fadeIn(350);
        $("#mail").fadeIn(350);
        $("#sendmail").fadeOut(0);
        if(data.nearpostoffice) {
            $("#sendmail").fadeIn(350);
            $("#sendmail").click(function(e) {
                console.log(data.mail.mailid);
                $.post("https://flex-mail/sendmail", JSON.stringify({
                    mailid: data.mail.mailid
                }));
                close();
            });
        }
    } else if(data.type == 'write') {
        $("#mail").fadeOut(0);
        $("#mailcontainer").fadeIn(350);
        $("#writemail").fadeIn(350);
        $("#formsubmit").click(function(e) {
            $.post("https://flex-mail/write", JSON.stringify({
                email: $("#fm").val(),
                subject: $("#fs").val(),
                mailtext: $("#ft").val(),
            }));
            close();
        });
    } else if(data.type == 'mailbox') {
        if (data.maillist[0] != null) {
            mails = data.maillist;
            $.each(mails, function (index, value) {
                $maillist += "<div id = 'mail" + value.mailid + "' class = '" + index + "'> <span> <p id = '" + index + "'>" + value.subject + "</p><i class='fa fa-trash' aria-hidden='true' style = 'margin-left:2vh' id = '" + value.mailid + "'></i></span></div>";
            });
            document.querySelector('#sidebar').innerHTML = $maillist;
            mailboxbuttons();
        } else {
            document.querySelector('#sidebar').innerHTML = '<p>You dont have any mail..</p>';
        }
        $("#sidebarcontainer").fadeIn(350);
        $("#sidebar").fadeIn(350);
    }
});

function mailboxbuttons() {
    $(".fa-trash").click(function(e) {
        mails = $.grep(mails, function(element, index) {
            return element.mailid != e.target.id;
        });
        $("#mail" + e.target.id).remove();
        $.post("https://flex-mail/deleteMail", JSON.stringify({ mailid: e.target.id}));
        if (mails.length === 0 || mails.length <= 0){
            document.querySelector('#sidebar').innerHTML = '<p>You dont have any mail..</p>';
        }
        $("#writemail").fadeOut(0);
        $("#mailcontainer").fadeOut(350);
        $("#mail").fadeOut(350);
        $("#sendmail").fadeOut(350);
    });
    $("#sidebar p").click(function(e) {
        document.querySelector('#email').innerHTML = mails[e.target.id].sender;
        document.querySelector('#subject').innerHTML = '<p>' + mails[e.target.id].subject  + '</p>';
        var converter = new showdown.Converter(),
        text = mails[e.target.id].mail,
        mail = converter.makeHtml(text);
        document.querySelector('#mailtext').innerHTML = mail;
        $("#writemail").fadeOut(0);
        $("#mailcontainer").fadeIn(350);
        $("#mail").fadeIn(350);
        $("#sendmail").fadeOut(350);
    });
};

$( function() {
    $("body").on("keydown", function (key) {
        if (key.keyCode == 27) {
            close();
        }
    });
});

function close() {
    $("#mailcontainer").fadeOut(350);
    $("#sidebarcontainer").fadeOut(350);
    $("#sidebar").fadeOut(350);
    $("#mail").fadeOut(350);
    $("#writemail").fadeOut(350);
    $("#sendmail").fadeOut(350);
    if (mails.length > 0){
        mails.length = 0;
        $maillist = ""; 
        $("#sidebar").empty();
    }
    $.post("https://flex-mail/CloseNui", JSON.stringify({}));
}