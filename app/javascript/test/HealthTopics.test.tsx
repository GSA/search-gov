import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { HealthTopics } from '../components/Results/HealthTopics/HealthTopics';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('HealthTopics component', () => {
  const healthTopic = {
    description: "A1C is a blood test for type 2 diabetes and prediabetes.",
    title: "A1C",
    url: "https://medlineplus.gov/a1c.html",
    relatedTopics: [{
      title: "Legionnaires Disease",
      url: "https://medlineplus.gov/legionnairesdisease.html"
    }],
    studiesAndTrials: [{
      title: "Pneumonia",
      url: "https://clinicaltrials.gov/search?cond=%22Pneumonia%22&aggFilters=status:not%20rec"
    }]
  };

  it('renders federal register component', () => {
    render(
      <HealthTopics {...healthTopic} />
    );
  });

  it('shows related topics title, url and description', () => {
    render(
      <HealthTopics {...healthTopic} />
    );
    expect(screen.getByText('A1C')).toBeInTheDocument();
    expect(screen.getByText('A1C is a blood test for type 2 diabetes and prediabetes.')).toBeInTheDocument();
  });

  it('shows related topics title and description', () => {
    render(
      <HealthTopics {...healthTopic} />
    );
    expect(screen.getByText('Legionnaires Disease')).toBeInTheDocument();
    expect(screen.getByText('Pneumonia')).toBeInTheDocument();
  });
});
