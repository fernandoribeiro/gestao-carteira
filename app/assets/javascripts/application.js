//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap-select
//= require_tree .

jQuery(function($) {
  // inicializar_selectpickers();
  // inicializar_selectable();
  // inicializar_um_selectable();
});

var $NOTICE = {
  show: function(sclass, strong, text){
    var $div = $('<div></div>');
    $div.addClass('alert');
    $div.addClass(sclass);
    $div.addClass('alert-section');

    var $button = $('<button></button>');
    $button.html('&times;');
    $button.addClass('close');
    $div.append($button);

    $button.click(function(){
      $div.slideUp(function(){
        $div.remove();
      });
    });

    var $strong = $('<strong></strong>');
    $strong.html(strong);
    $div.append($strong);

    $div.append(' '+text);

    $div.hide();
    $('#notice_over').html($div);
    $div.slideDown();

    window.setTimeout(function(){
      $div.slideUp(function(){
        $div.remove();
      });
    }, 20000)
  },

  info: function(text){
    this.show('alert-info', 'Veja.', text);
  },

  block: function(text){
    this.show('alert-block', 'Cuidado!', text);
  },

  error: function(text){
    this.show('alert-error', 'Erro!', text);
  },

  success: function(text){
    this.show('alert-success', 'Ok!', text);
  },
}

// function inicializar_selectpickers() {
//   $('select').selectpicker();
// }

function initializeDecimalMask() {
  $('.decimal').maskMoney({
    showSymbol: false,
    decimal: '.',
    thousands: '',
    allowZero: true
  });
}

function initializeNumericMask() {
  $('.numeric').ForceNumericOnly();
}
