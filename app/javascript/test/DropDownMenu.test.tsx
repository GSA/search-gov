import '@testing-library/jest-dom';

import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';

import { DropDownMenu } from '../components/VerticalNav/DropDownMenu';

describe('DropDownMenu', () => {
  it('closes when clicked outside', () => {
    const item = <div>Menu Item</div>;

    render(
      <DropDownMenu label='show more' items={[item]} />
    );

    const menuItem = screen.queryByText('Menu Item');

    expect(menuItem).not.toBeVisible();

    fireEvent.click(screen.getByText(/show more/i));

    expect(menuItem).toBeVisible();

    fireEvent.click(document.body);

    expect(menuItem).not.toBeVisible();
  });
});
