import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import parse from 'html-react-parser';

import { Jobs } from '../components/Results/Jobs/Jobs';

Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn()
  }))
});

describe('Jobs component', () => {
  const jobsProps = {
    jobs: [
      {
        positionTitle: 'Contract Specialist',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocationDisplay: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 20, 2023'
      },
      {
        positionTitle: 'Contract Specialist 2',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocationDisplay: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 2',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 21, 2023'
      },
      {
        positionTitle: 'Contract Specialist 3',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocationDisplay: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 3',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 22, 2023'
      },
      {
        positionTitle: 'Contract Specialist 4',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocationDisplay: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 4',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 23, 2023'
      },
      {
        positionTitle: 'Contract Specialist 5',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocationDisplay: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 5',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 24, 2023'
      }
    ],
    recommendedBy: 'gsa',
    parse
  };

  it('renders Jobs component', () => {
    render(
      <Jobs {...jobsProps}/>
    );
  });

  it('shows Jobs details', () => {
    render(
      <Jobs {...jobsProps}/>
    );
    expect(screen.getByText('Contract Specialist')).toBeInTheDocument();
    expect(screen.getByText('Office of Acquisition and Logistics')).toBeInTheDocument();
  });
});
