import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';
import { SpellingSuggestion } from '../components/Results/SpellingSuggestion/SpellingSuggestion';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('Alert component', () => {
  const spellingSuggestionProps = {
    suggested: '<a href=\"/search?affiliate=test_alert&amp;query=government\">government</a>',
    original: '<a href=\"/search?affiliate=test_alert&amp;query=%2Bgovermment\">govermment</a>'
  };

  it('renders SpellingSuggestion component', () => {
    render(
      <SpellingSuggestion {...spellingSuggestionProps} />
    );
  });
});
