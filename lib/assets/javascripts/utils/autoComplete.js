import debounce from '../utils/debounce';
import { isObject } from '../utils/isType';
import { isValidText } from '../utils/isValidInputType';

/*
 * Looks up the id for the text selected by the user in the jquery autocomplete combobox and
 * then sets updates the hidden id field with the id value so that its available on form submit.
 * The id-text mappings are stored as JSON in the corresponding hidden crosswalk field
 * @param the combobox element
 */
const updateIdField = (el) => {
  const crosswalk = $(`#${$(el).attr('id')}_crosswalk`);
  const idField = $(el).attr('id').replace(/_name/, '_id');

  if (isObject(crosswalk) && isObject($(idField))) {
    const json = JSON.parse(`${$(crosswalk).val().replace(/\\"/g, '"').replace(/\\'/g, '\'')}`);
    const selection = (json[$(el).val()] === undefined ? '' : json[$(el).val()]);
    $(el).parent().siblings(`#${idField}`).val(selection);
  }
};

/*
 * Shows/hides the combobox's clear button based on whether or not text is present
 * @param the combobox id
 */
const toggleClearButton = (el) => {
  const clearButton = $(el).parent().find('.combobox-clear-button');
  if (isObject(clearButton)) {
    if (isValidText($(el).val())) {
      $(clearButton).removeClass('hidden');
    } else {
      $(clearButton).addClass('hidden');
    }
  }
};

/*
 * Wires up the jquery autocomplete combobox so that it calls the above 2 functions when the
 * user changes the text values in the combobox by typing or selecting a value
 */
export default () => {
  $('.js-combobox').each((idx, el) => {
    // Swap out the 'X' with a fontawesome icon
    $(el).siblings('.combobox-clear-button').text('')
      .addClass('fa')
      .addClass('fa-times-circle');

    const debounced = debounce((e) => {
      toggleClearButton(e);
      updateIdField(e);
    }, 100);

    // When the value in the combobox changes update the hidden id field
    $(el).on('keyup blur', (e) => {
      debounced($(e.currentTarget));
    });

    // Clear the text and hide the button when the user clicks the clear button
    $(el).parent().find('.combobox-clear-button').on('click', () => {
      $(el).val('');
      debounced(el);
    });

    // add a Bootstrap 'hide' class to the invisible help text
    $('.invisible').addClass('hide');

    // Show/hide the clear button on page load
    toggleClearButton(el);
  });
};