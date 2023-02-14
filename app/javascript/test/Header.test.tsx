import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import {Header} from '../components/Header';

describe('Header', () => {
  it('shows agency title and links in the basic header', () => {
    render(<Header title="Search.gov" isBasic={true} />);
    const title = screen.getByText(/Search.gov/i);
    const navLinkTitle = screen.getByText(/<Current section>/i);
    expect(title).toBeInTheDocument();
    expect(navLinkTitle).toBeInTheDocument();

    const btn1 = screen.getByTestId("current-section");
    fireEvent.click(btn1);
    expect(screen.getByText("<Navigation link 1>")).toBeInTheDocument();

    const btn2 = screen.getByTestId("current-section-2");
    fireEvent.click(btn2);
    expect(screen.getByText("<Section link 1>")).toBeInTheDocument();

    //To Do - investigate test cases for responsive
    const btn3 = screen.getByTestId("usa-menu-mob-btn"); //Menu button for mobile
    fireEvent.click(btn3);
    expect(navLinkTitle).toBeInTheDocument();
    
  });

  it('shows agency title and links in the extended header', () => {
    render(<Header title="Search.gov" isBasic={false} />);
    const privacyPolicy = screen.getAllByText(/Privacy policy/i)[0];
    const updates = screen.getAllByText(/Latest updates/i)[0];
    expect(privacyPolicy).toBeInTheDocument();
    expect(updates).toBeInTheDocument();

    const btnNavLabel = screen.getByTestId("nav-label");
    fireEvent.click(btnNavLabel);
    expect(screen.getByText("Navigation link 1")).toBeInTheDocument();
  });

  //To Do - update this test once search bar submit func is integrated
  it('click search bar', () => {
    render(<Header title="Search.gov" isBasic={true} />);
    const btnHeaderSearch = screen.getByTestId("button");
    fireEvent.click(btnHeaderSearch);
    expect(screen.getByText("<Current section>")).toBeInTheDocument();
  });
});
