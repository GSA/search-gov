/* eslint-disable camelcase */

import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import moment from 'moment';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

import { FedRegister } from '../components/Results/FedRegister/FedRegister';

const fedRegisterDocs = [
  {
    title: 'Expand the Definition of a Public Assistance Household',
    htmlUrl: 'https://gsa.gov/',
    commentsCloseOn: 'October 12, 2024',
    contributingAgencyNames: ['Social Security Administarion', 'GSA'],
    documentNumber: '2016-10932',
    documentType: 'Proposed Rule',
    publicationDate: 'January 02, 2020',
    startPage: 29212,
    endPage: 29215,
    pageLength: 4
  },
  {
    title: 'Unsuccessful Work Attempts and Expedited Reinstatement Eligibility',
    htmlUrl: 'https://www.federalregister.gov/articles/2016/05/11/2016-10932/unsuccessful-work-attempts-and-expedited-reinstatement-eligibility',
    commentsCloseOn: 'April 05, 2022',
    contributingAgencyNames: ['Social Security Administarion'],
    documentNumber: '2013-18148',
    documentType: 'Rule',
    publicationDate: 'January 02, 2020',
    startPage: 29212,
    endPage: 29215,
    pageLength: 5
  },
  {
    title: 'Unsuccessful Work Attempts and Expedited Reinstatement Eligibility',
    htmlUrl: 'https://www.federalregister.gov/articles/2016/05/11/2016-10932/unsuccessful-work-attempts-and-expedited-reinstatement-eligibility',
    commentsCloseOn: moment().format('MMM DD, YYYY'),
    contributingAgencyNames: ['Social Security Administarion'],
    documentNumber: '2013-18148',
    documentType: 'Rule',
    publicationDate: 'January 02, 2020',
    startPage: 29212,
    endPage: 29215,
    pageLength: 5
  },
  {
    title: 'Unsuccessful Work Attempts and Expedited Reinstatement Eligibility 2',
    htmlUrl: 'https://www.federalregister.gov/articles/2016/05/11/2016-109323/unsuccessful-work-attempts-and-expedited-reinstatement-eligibility2',
    commentsCloseOn: null,
    contributingAgencyNames: ['Social Security Administarion 2'],
    documentNumber: '2013-18148',
    documentType: 'Rule',
    publicationDate: 'January 02, 2020',
    startPage: 29212,
    endPage: 29215,
    pageLength: 5
  }
];

describe('FedRegister component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  it('renders federal register component', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} query='government' affiliate='boos_affiliate' vertical='web'/>
    );
  });

  it('shows title', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} query='government' affiliate='boos_affiliate' vertical='web'/>
    );
    expect(screen.getByText('Expand the Definition of a Public Assistance Household')).toBeInTheDocument();
  });

  it('shows agency names and pages count', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} query='government' affiliate='boos_affiliate' vertical='web'/>
    );
    expect(screen.getByText('A Proposed Rule by the GSA and the Social Security Administarion posted on January 02, 2020.')).toBeInTheDocument();
    expect(screen.getByText('Pages 29212 - 29215 (4 pages) [FR DOC #: 2016-10932]')).toBeInTheDocument();
  });

  it('shows comment ends today', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} query='government' affiliate='boos_affiliate' vertical='web'/>
    );
    expect(screen.getByText('Comment period ends today')).toBeInTheDocument();
  });

  it('shows comment period ends in x days', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} query='government' affiliate='boos_affiliate' vertical='web'/>
    );
    expect(screen.getByText('Comment period ends in ', { exact: false })).toBeInTheDocument();
  });

  it('calls fetch with correct federal reg document click data', () => {
    render(<FedRegister fedRegisterDocs={fedRegisterDocs} query='government' affiliate='boos_affiliate' vertical='web'/>);

    const link = screen.getByText(/Expand the Definition of a Public Assistance Household/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'https://gsa.gov/',
      module_code: 'FRDOC',
      position: 1,
      query: 'government',
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

  it('calls fetch with correct federal reg document click data for More agency docs link', () => {
    render(<FedRegister fedRegisterDocs={fedRegisterDocs} query='government' affiliate='boos_affiliate' vertical='web'/>);

    const link = screen.getByText(/More agency documents on FederalRegister.gov/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'https://www.federalregister.gov/articles/search?conditions%5Bagency_ids%5D%5B%5D=470&conditions%5Bterm%5D=government',
      module_code: 'FRDOC',
      position: fedRegisterDocs.length + 1,
      query: 'government',
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

describe('Mobile view: FedRegister component clicking the content div', () => {
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

  it('calls fetch with correct federal reg document click data', () => {
    render(<FedRegister fedRegisterDocs={fedRegisterDocs} query='government' affiliate='boos_affiliate' vertical='web'/>);

    const desc = screen.getByText(/Proposed Rule/i);
    fireEvent.click(desc);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'https://gsa.gov/',
      module_code: 'FRDOC',
      position: 1,
      query: 'government',
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
