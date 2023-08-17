import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { FedRegister } from '../components/Results/FedRegister/FedRegister';

describe('FedRegister component', () => {
  it('renders federal register component', () => {
    render(
      <FedRegister />
    );
  });

  it('shows title', () => {
    render(
      <FedRegister />
    );
    expect(screen.getByText('Federal Register documents about Benefits')).toBeInTheDocument();
  });
});
