import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { Alert } from '../components/Alert/Alert';

describe('Alert component', () => {
  const alertProps = {
    title: 'Attention',
    text: 'Description'
  };

  it('renders Alert component', () => {
    render(
      <Alert {...alertProps} />
    );
  });

  it('shows Alert title and description', () => {
    render(
      <Alert {...alertProps} />
    );
    expect(screen.getByText('Attention')).toBeInTheDocument();
    expect(screen.getByText('Description')).toBeInTheDocument();
  });
});
