import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { Header } from '../components/Header';

const fontsAndColors = {
  headerLinksFontFamily: '"Georgia", "Cambria", "Times New Roman", "Times", serif'
};

describe('Header', () => {
  it('shows agency title and links in the basic header', () => {
    render(<Header title='Search.gov' isBasic={true} fontsAndColors={fontsAndColors} />);
    const title = screen.getByText(/Search.gov/i);
    expect(title).toBeInTheDocument();

    const primaryLinkTitle = screen.getByText(/Primary link 1/i);
    expect(primaryLinkTitle).toBeInTheDocument();

    const secondaryLinkTitle = screen.getByText(/Secondary link 1/i);
    expect(secondaryLinkTitle).toBeInTheDocument();

    // To Do - investigate test cases for responsive
    const btn = screen.getByTestId('usa-menu-mob-btn'); // Menu button for mobile
    fireEvent.click(btn);
    expect(primaryLinkTitle).toBeInTheDocument();
  });

  it('shows agency title and links in the extended header', () => {
    render(<Header title='Search.gov' isBasic={false} fontsAndColors={fontsAndColors} />);

    const title = screen.getByText(/Search.gov/i);
    expect(title).toBeInTheDocument();

    const primaryLinkTitle = screen.getByText(/Primary link 1/i);
    expect(primaryLinkTitle).toBeInTheDocument();

    const secondaryLinkTitle = screen.getByText(/Secondary link 1/i);
    expect(secondaryLinkTitle).toBeInTheDocument();
  });

  it('uses declared headerLinksFontFamily font', () => {
    render(<Header title='Search.gov' isBasic={false} fontsAndColors={fontsAndColors} />);

    const primaryLinkTitle = screen.getByText(/Primary link 1/i);
    expect(primaryLinkTitle).toHaveStyle({
      'font-family': '"Georgia", "Cambria", "Times New Roman", "Times", serif'
    });

    const secondaryLinkTitle = screen.getByText(/Secondary link 1/i);
    expect(secondaryLinkTitle).toHaveStyle({
      'font-family': '"Georgia", "Cambria", "Times New Roman", "Times", serif'
    });
  });
});
