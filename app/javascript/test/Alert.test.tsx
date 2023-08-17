import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { Alert } from '../components/Alert/Alert';

describe('Alert component', () => {
  it('renders Alert component', () => {
    render(
      <Alert />
    );
  });

  it('shows Alert title', () => {
    render(
      <Alert />
    );
    expect(screen.getByText('Attention')).toBeInTheDocument();
  });
});
