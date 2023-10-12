import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

type FedRegisterDocs = {
  commentsCloseOn: string;
  contributingAgencyNames: [string];
  documentNumber: string;
  documentType: string;
  endPage: number;
  htmlUrl: string;
  pageLength: number;
  publicationDate: string;
  startPage: number;
  title: string;
}[];
interface FedRegisterDocsProps {
  fedRegisterDocs?: FedRegisterDocs;
}

function federal_register_document_info(document) {
  var document_type_span = document.documentType;
  var fr_agency_names = document.contributingAgencyNames;
  var fr_agencies_html = federal_register_agencies_html(fr_agency_names);
  var publication_date_span = document.publicationDate
  return "A " + document_type_span + " " + fr_agencies_html + " posted on " + publication_date_span + ".";
}

function federal_register_agencies_html(fr_agency_names) {
  var agency_spans = fr_agency_names.sort().map(function(name) {
      return name;
  });
  var last_agency_span = agency_spans.pop();
  var agencies_html = 'by the ' + agency_spans.join(', the ');
  if (agency_spans.length > 0) {
      agencies_html += ' and the ';
  }
  agencies_html += last_agency_span;
  return agencies_html;
}

function federal_register_document_page_info(document) {
    var content = 'Pages ' + document.startPage + ' - ' + document.endPage + ' ';
    content += '(' + document.pageLength + ' page) ';
    content += '[FR DOC #: ' + document.documentNumber + ']';
    return content;
}

const isToday = (someDate) => {
  const today = new Date()
  someDate = new Date(someDate)
  return someDate.getDate() == today.getDate() &&
    someDate.getMonth() == today.getMonth() &&
    someDate.getFullYear() == today.getFullYear()
}

function federal_register_document_comment_period(document) {
  if (!document.commentsCloseOn) {
    return;
  }

  var today = new Date().getTime();
  var commentsCloseOn = new Date(document.commentsCloseOn).getTime();
  
  if(isToday(document.commentsCloseOn)){
    return (<div className='comment-period'>Comment period ends today</div>);
  }else{
    if (commentsCloseOn < today)
      return (<div className='comment-period-ended'>Comment Period Closed</div>);
    else{
      var dateDelta = Math.floor((commentsCloseOn - today) / (1000 * 60 * 60 * 24));
      var dateDeltaSpan = dateDelta === 1 ? '1 day' : dateDelta + ' days';
      var commentsCloseOnSpan = document.commentsCloseOn ;
      return (<div className='comment-period'>{'Comment period ends in ' + dateDeltaSpan + ' (' + commentsCloseOnSpan + ')'}</div>);
    }
  }
}

export const FedRegister = ({ fedRegisterDocs=[] }: FedRegisterDocsProps) => {
  return (
    <>
      {fedRegisterDocs?.length > 0 && (
        <div className='search-item-wrapper fed-register-item-wrapper'>
          <GridContainer className='fed-register-wrapper'>
            <Grid row gap="md">
              <h2 className='fed-register-label'>
                Federal Register documents about Benefits
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
                      <a href={fedRegisterDoc.htmlUrl} className='result-title-link'>
                        <h2 className='result-title-label'>
                          {parse(fedRegisterDoc.title)} 
                        </h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>
                        {federal_register_document_info(fedRegisterDoc)} 
                        {/* A {parse(fedRegisterDoc.documentType)} by {fedRegisterDoc.contributingAgencyNames} */}
                      </p>
                      <div className='pages-count'>
                        {federal_register_document_page_info(fedRegisterDoc)}
                        {/* Pages 29212 - 29215 (4 pages) [FR DOC #: 2016-10932] */}
                      </div>

                      {federal_register_document_comment_period(fedRegisterDoc)}

                      {/* {federal_register_document_comment_period(fedRegisterDoc) && (
                        <div className='comment-period'>
                          {federal_register_document_comment_period(fedRegisterDoc)}
                        </div>
                      )} */}
                    </div>
                  </Grid>
                </Grid>
                <Grid row className="row-mobile-divider"></Grid>
              </GridContainer>
              );
          })}

          <GridContainer className='result-divider'>
            <Grid row gap="md">
            </Grid>
          </GridContainer>
        </div>
      )}
    </>
  );
};
