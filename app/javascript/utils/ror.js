import getConstant from '../constants';
import { isObject } from '../../utils/isType';
import { isValidText } from '../../utils/isValidInputType';

/* Provides ROR Organization auto-complete functionality */
var ror_disable;

const ajaxSearch = (request, response) => {
  $.ajax({
    url: getConstant('ORG_AUTOCOMPLETE_PATH'),
    dataType: 'json',
    data: { term: request.term },
    success: (data) => {
      response($.map(data, (item) => {
        return { value: item.name, id: item.id }
      }));
    }
  });
};

export const initOrgSelection = (options) => {
  if (isObject(options) && options.selector) {
    const div = $(options.selector);

    if (isObject(div)) {
      const combo = div.find('input.js-autocomplete');
      const id = div.find('input.org-id');
      const name = div.find('input[name="user[org_name]"]');

      combo.on('keydown', (e) => {
        if (e.keyCode === $.ui.keyCode.TAB && combo.autocomplete('instance').menu.active) {
          e.preventDefault;
        }
      });

      combo.autocomplete({
        minLength: 1,
        source: (request, response) => {
          id.val('');
          ajaxSearch(request, response);
        },
        focus: () => { return false; },
        select: (e, ui) => { id.val(ui.item.id); },
        open: (e, ui) => { disable = true },
        close: (e, ui) => {
          disable = false;
          combo.focus();
        }
      });
    }
  }
};
