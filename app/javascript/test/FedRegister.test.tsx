import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import moment from 'moment';

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
  it('renders federal register component', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} />
    );
  });

  it('shows title', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} />
    );
    expect(screen.getByText('Expand the Definition of a Public Assistance Household')).toBeInTheDocument();
  });

  it('shows agency names and pages count', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} />
    );
    expect(screen.getByText('A Proposed Rule by the GSA and the Social Security Administarion posted on January 02, 2020.')).toBeInTheDocument();
    expect(screen.getByText('Pages 29212 - 29215 (4 page) [FR DOC #: 2016-10932]')).toBeInTheDocument();
  });

  it('shows comment ends today', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} />
    );
    expect(screen.getByText('Comment period ends today')).toBeInTheDocument();
  });

  it('shows comment period ends in x days', () => {
    render(
      <FedRegister fedRegisterDocs={fedRegisterDocs} />
    );
    expect(screen.getByText('Comment period ends in ', { exact: false })).toBeInTheDocument();
  });
});
