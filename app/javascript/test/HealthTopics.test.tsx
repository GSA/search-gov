import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { HealthTopics } from '../components/Results/HealthTopics/HealthTopics';

describe('HealthTopics component', () => {
  it('renders federal register component', () => {
    render(
      <HealthTopics />
    );
  });

  it('shows related topics', () => {
    render(
      <HealthTopics />
    );
    expect(screen.getByText('Haemophilus Infections')).toBeInTheDocument();
  });
});
