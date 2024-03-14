/* eslint-disable camelcase */

import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';
import { LanguageContext } from '../contexts/LanguageContext';

import { Jobs } from '../components/Results/Jobs/Jobs';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

const locale = {
  en: {
    jobOpenings: 'Job Openings',
    atAgency: 'at %{agency}',
    federalJobOpenings: 'Federal Job Openings',
    searches: {
      moreFederalJobOpenings: 'More federal job openings on USAJobs.gov'
    }
  }
};

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

const i18n = new I18n(locale);

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

const jobsProps = {
  jobs: [
    {
      positionTitle: 'Contract Specialist 1',
      positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
      positionLocation: 'Multiple Locations',
      organizationName: 'Office of Acquisition and Logistics 1',
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
      organizationName: 'Office of Acquisition and Logistics 6',
      minimumPay: 122000,
      maximumPay: 150000,
      rateIntervalCode: 'Per Hour',
      applicationCloseDate: 'September 24, 2023'
    },
    {
      positionTitle: 'Contract Specialist 7',
      positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
      positionLocation: 'Multiple Locations',
      organizationName: 'Office of Acquisition and Logistics 7',
      minimumPay: 122000,
      maximumPay: 150000,
      rateIntervalCode: 'Without Compensation',
      applicationCloseDate: 'September 24, 2023'
    },
    {
      positionTitle: 'Contract Specialist 8',
      positionUri: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
      positionLocation: 'Multiple Locations',
      organizationName: 'Office of Acquisition and Logistics 8',
      minimumPay: 0,
      maximumPay: 150000,
      rateIntervalCode: 'PA',
      applicationCloseDate: 'September 24, 2023'
    }
  ],
  agencyName: 'USA.gov',
  query: 'jobs',
  affiliate: 'boos_affiliate',
  vertical: 'web'
};

const jobsProps2 = { 
  jobs: [
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
  ],
  query: 'jobs',
  affiliate: 'boos_affiliate',
  vertical: 'web'
};

describe('Jobs component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  it('renders Jobs component', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Jobs {...jobsProps} />
      </LanguageContext.Provider>
    );
    expect(screen.getByText('Job Openings at USA.gov')).toBeInTheDocument();
  });

  it('shows Jobs details', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Jobs {...jobsProps2} />
      </LanguageContext.Provider>
    );
    expect(screen.getByText('Federal Job Openings')).toBeInTheDocument();

    expect(screen.getByText('$122,000.00+/yr')).toBeInTheDocument();
    expect(screen.getByText('Contract Specialist 5')).toBeInTheDocument();
    expect(screen.getByText('Office of Acquisition and Logistics 5')).toBeInTheDocument();
  });

  it('calls fetch with correct jobs click data', () => {
    render(<Jobs {...jobsProps} />);

    const link = screen.getByText(/Contract Specialist 1/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
      module_code: 'JOBS',
      position: 1,
      query: 'jobs',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('calls fetch with correct jobs click data for More jobs link', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Jobs {...jobsProps} />
      </LanguageContext.Provider>
    );

    const link = screen.getByText(/More federal job openings on USAJobs.gov/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'https://www.usajobs.gov/Search/Results?hp=public',
      module_code: 'JOBS',
      position: jobsProps.jobs.length + 1,
      query: 'jobs',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('View More Jobs', () => {
    render(
      <Jobs {...jobsProps} />
    );

    expect(screen.getByText('Contract Specialist 8')).toBeInTheDocument();
    expect(screen.getByText('Office of Acquisition and Logistics 5')).toBeInTheDocument();

    const link = screen.getByText(/Contract Specialist 8/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
      module_code: 'JOBS',
      position: 8,
      query: 'jobs',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});

describe('Mobile view: Jobs component clicking the content div', () => {
  beforeAll(() => {
    window.innerWidth = 450;
  });

  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  it('calls fetch with correct jobs click data', () => {
    render(<Jobs {...jobsProps} />);

    const body = screen.getByText(/Office of Acquisition and Logistics 1/i);
    fireEvent.click(body);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
      module_code: 'JOBS',
      position: 1,
      query: 'jobs',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('more jobs: calls fetch with correct jobs click data', () => {
    render(<Jobs {...jobsProps} />);

    const body = screen.getByText(/Office of Acquisition and Logistics 8/i);
    fireEvent.click(body);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'https://www.usajobs.gov/GetJob/ViewDetails/690037300',
      module_code: 'JOBS',
      position: 8,
      query: 'jobs',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});
