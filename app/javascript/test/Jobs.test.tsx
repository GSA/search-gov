import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { Jobs } from '../components/Results/Jobs/Jobs';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

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
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 20, 2023'
      },
      {
        positionTitle: 'Contract Specialist 2',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 2',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 21, 2023'
      },
      {
        positionTitle: 'Contract Specialist 3',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 3',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 22, 2023'
      },
      {
        positionTitle: 'Contract Specialist 4',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 4',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 23, 2023'
      },
      {
        positionTitle: 'Contract Specialist 5',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 5',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'Per Year',
        applicationCloseDate: 'September 24, 2023'
      },
      {
        positionTitle: 'Contract Specialist 6',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 5',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'Per Hour',
        applicationCloseDate: 'September 24, 2023'
      },
      {
        positionTitle: 'Contract Specialist 7',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 5',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'Without Compensation',
        applicationCloseDate: 'September 24, 2023'
      },
      {
        positionTitle: 'Contract Specialist 8',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 5',
        minimumPay: 0,
        maximumPay: 150000,
        rateIntervalCode: 'PA',
        applicationCloseDate: 'September 24, 2023'
      }
    ]
  };

  it('renders Jobs component', () => {
    render(
      <Jobs {...jobsProps}/>
    );
  });

  it('shows Jobs details', () => {
    const jobsProps2 = { jobs: [
      {
        positionTitle: 'Contract Specialist 5',
        positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
        positionLocation: 'Multiple Locations',
        organizationName: 'Office of Acquisition and Logistics 5',
        minimumPay: 122000,
        maximumPay: 150000,
        rateIntervalCode: 'Per Year',
        applicationCloseDate: 'September 24, 2023'
      }
    ] };

    render(
      <Jobs {...jobsProps2}/>
    );
    expect(screen.getByText('$122,000.00+/yr')).toBeInTheDocument();
    expect(screen.getByText('Contract Specialist 5')).toBeInTheDocument();
    expect(screen.getByText('Office of Acquisition and Logistics 5')).toBeInTheDocument();
  });
});
