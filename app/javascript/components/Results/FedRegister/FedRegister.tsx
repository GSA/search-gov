import React, { useContext } from 'react';
import styled from 'styled-components';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import moment from 'moment';
import { StyleContext } from '../../../contexts/StyleContext';

type FedRegisterDoc = {
  commentsCloseOn: string | null;
  contributingAgencyNames: string[];
  documentNumber: string;
  documentType: string;
  endPage: number;
  htmlUrl: string;
  pageLength: number;
  publicationDate: string;
  startPage: number;
  title: string;
};

interface FedRegisterDocsProps {
  fedRegisterDocs?: FedRegisterDoc[];
  query?:string;
}

const StyledWrapper = styled.div.attrs<{ styles: { sectionTitleColor: string }; }>((props) => ({
  styles: props.styles
}))`
  .fed-register-label {
    color: ${(props) => props.styles.sectionTitleColor};
  }
`;

const getFedRegDocInfo = (document: FedRegisterDoc) => {
  const docType = document.documentType;
  const agencyNames = document.contributingAgencyNames;
  const agenciesHtml = agencyNames.length > 0 ? getFedRegisterAgenciesText(agencyNames): '';
  const pubDate = document.publicationDate;
  return `A ${docType} ${agenciesHtml} posted on ${pubDate}.`;
};

const getFedRegisterAgenciesText = (agencyNames: string[]) => {
  const agencyText = agencyNames.sort().map((name) => name);
  const lastAgencyText = agencyText.pop();
  let agencies = `by the ${agencyText.join(', the ')}`;
  if (agencyText.length > 0) {
    agencies += ' and the ';
  }
  agencies += lastAgencyText;
  return agencies;
};

const getFedRegDocPageInfo = (document: FedRegisterDoc) => {
  let content = `Pages ${document.startPage} - ${document.endPage} `;
  content += document.pageLength === 1 ? `(${document.pageLength} page) ` : `(${document.pageLength} pages) `;
  content += `[FR DOC #: ${document.documentNumber}]`;
  return content;
};

const isToday = (dateStr: string) => {
  const today = new Date();
  const someDate = new Date(dateStr);
  return someDate.getDate() === today.getDate() &&
    someDate.getMonth() === today.getMonth() &&
    someDate.getFullYear() === today.getFullYear();
};

const getFedRegDocCommentPeriod = (document: FedRegisterDoc) => {
  if (!document.commentsCloseOn) {
    return;
  }
  const today = new Date().getTime();
  const commentsCloseOn = new Date(document.commentsCloseOn).getTime();

  if (isToday(document.commentsCloseOn))
    return (<div className='comment-period'>Comment period ends today</div>);

  if (commentsCloseOn < today)
    return (<div className='comment-period-ended'>Comment Period Closed</div>);

  const dateDelta = moment(document.commentsCloseOn).diff(moment().format('MMM DD, YYYY'), 'days');
  const dateDeltaSpan = dateDelta === 1 ? '1 day' : `${dateDelta} days`;
  const commentsCloseOnSpan = document.commentsCloseOn ;
  return (<div className='comment-period'>{`Comment period ends in ${dateDeltaSpan} (${commentsCloseOnSpan})`}</div>);
};

const getAgencyFedUrl = (query: string) => {
  const agencyIds = 470;
  const moreFedUrl = `https://www.federalregister.gov/articles/search?conditions[agency_ids][]=${agencyIds}&conditions[term]=${query}`;
  return encodeURI(moreFedUrl);
};

export const FedRegister = ({ fedRegisterDocs=[], query='' }: FedRegisterDocsProps) => {
  const styles = useContext(StyleContext);

  return (
    <>
      {fedRegisterDocs?.length > 0 && (
        <StyledWrapper styles={styles}>
          <div className='search-item-wrapper fed-register-item-wrapper'>
            <GridContainer className='fed-register-wrapper'>
              <Grid row gap="md">
                <h2 className='fed-register-label'>
                  Federal Register documents about {query}
                </h2>
              </Grid>
            </GridContainer>
            
            {fedRegisterDocs?.map((fedRegisterDoc, index) => {
              return (
                <GridContainer className='result search-result-item' key={index}>
                  <Grid row gap="md">
                    <Grid col={true} className='result-meta-data'>
                      <span className='published-date'>{fedRegisterDoc.publicationDate}</span>
                      
                      <div className='result-title'>

                        <h2 className='result-title-label'>
                          <a href={fedRegisterDoc.htmlUrl} className='result-title-link'>
                            {parse(fedRegisterDoc.title)}
                          </a>
                        </h2>
                        
                        {/* 
                        <a href={fedRegisterDoc.htmlUrl} className='result-title-link'>
                          <h2 className='result-title-label'>
                            {parse(fedRegisterDoc.title)} 
                          </h2>
                        </a> 
                        */}
                      </div>
                      <div className='result-desc'>
                        <p>{getFedRegDocInfo(fedRegisterDoc)}</p>
                        <div className='pages-count'>{getFedRegDocPageInfo(fedRegisterDoc)}</div>
                        {getFedRegDocCommentPeriod(fedRegisterDoc)}
                      </div>
                    </Grid>
                  </Grid>
                  <Grid row className="row-mobile-divider"></Grid>
                </GridContainer>
              );
            })}

            <GridContainer className='result search-result-item'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <div className='result-title'>
                    
                    <h2 className='result-title-label'>
                      <a href={getAgencyFedUrl(query)} className='result-title-link more-title-link'>
                        More agency documents on FederalRegister.gov
                      </a>
                    </h2>
                    {/* <a href={getAgencyFedUrl(query)} className='result-title-link more-title-link'>
                      <h2 className='result-title-label'>
                        More agency documents on FederalRegister.gov
                      </h2>
                    </a> */}
                  </div>
                </Grid>
              </Grid>
            </GridContainer>

            <GridContainer className='result-divider'>
              <Grid row gap="md">
              </Grid>
            </GridContainer>
          </div>
        </StyledWrapper>
      )}
    </>
  );
};
