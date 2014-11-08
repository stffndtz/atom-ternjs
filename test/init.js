var TSTSTS = function () {

    var that = this;

    this.$html = $('html');
    this.$body = $('body');
    this.$htmlBody = $('html, body');
    this.$window = $(window);
    this.$document = $(document);
    this.$content = $('#content');

    this.stdEvent = 'click';

    this.init = function () {

        this.$document.on('docContentAppended', function (e) {

            that.registerHandler(e.target);
        });

        this.registerHandler(this.$document);
    };

    this.registerHandler = function ($context) {

    };
};

$(function () {

    tststs = new TSTSTS();
    tststs.init();
});
