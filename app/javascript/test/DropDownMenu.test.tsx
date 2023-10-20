import '@testing-library/jest-dom';

import React from 'react';
import { I18n } from 'i18n-js';
import { LanguageContext } from '../contexts/LanguageContext';
import { render, screen, fireEvent } from '@testing-library/react';

import { DropDownMenu } from '../components/VerticalNav/DropDownMenu';

jest.mock('i18n-js', () => jest.requireActual('i18n-js/dist/require/index'));

const locale = { en: { showMore: 'More' } };

const i18n = new I18n(locale);

describe('DropDownMenu', () => {
  it('closes when clicked outside', () => {
    const item = <div>Menu Item</div>;

    render(
      <LanguageContext.Provider value={i18n} >
        <DropDownMenu label='showMore' items={[item]} />
      </LanguageContext.Provider>
    );

    const menuItem = screen.queryByText('Menu Item');

    expect(menuItem).not.toBeVisible();

    fireEvent.click(screen.getByText(/More/i));

    expect(menuItem).toBeVisible();

    fireEvent.click(document.body);

    expect(menuItem).not.toBeVisible();
  });
});
