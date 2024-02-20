import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

interface GraphicsBestBetProps {
  title: string;
  titleUrl?: string;
  imageUrl?: string;
  imageAltText?: string;
  links?: {
    title: string;
    url: string;
  }[];
}

export const GraphicsBestBet = ({ title, titleUrl, imageUrl, imageAltText, links }: GraphicsBestBetProps) => {
  // This method reorders links so that they appear in column order.
  const sortedLinks = (links: {title: string, url: string}[]) => {
    if (links.length <= 2) {
      return links;
    }

    const order = [];
    let rightColumnIndex = 1;
    for (let index = 0; index < links.length; index += 1) {
      if (index < Math.ceil(links.length/2)) {
        order.push(2 * index);  
      } else {
        order.push(rightColumnIndex);
        rightColumnIndex += 2;
      }
    }

    const reorderedLinks = [];
    for (let index = 0; index < links.length; index += 1) {
      reorderedLinks[order[index]] = links[index];
    }
    return reorderedLinks;
  };

  return (
    <GridContainer className='result search-result-item graphics-best-bets featured-collection'>
      <Grid row gap="md">
        {imageUrl && (
          <Grid mobileLg={{ col: 2 }} className='result-thumbnail'>
            <img src={imageUrl} alt={imageAltText && imageAltText} className="result-image"/>
          </Grid>
        )}
        <Grid col={true} className='result-meta-data'>
          <div className='graphics-best-bets-title result-title'>
            {titleUrl ? (
              <h2 className='result-title-label'><a href={titleUrl} className='result-title-link'>{parse(title)}</a></h2>) : <h2 className='result-title-label'>{parse(title)}</h2>}
          </div>
          {/* 
          <div className='graphics-best-bets-title result-title'>
            {titleUrl ? (
              <a href={titleUrl} className='result-title-link'><h2 className='result-title-label'>{parse(title)}</h2></a>) : <h2 className='result-title-label'>{parse(title)}</h2>}
          </div> 
          */}
          {links && links.length > 0 && (
            <Grid row gap="md">
              {sortedLinks(links).map((link, index) => {
                return (
                  <Grid key={index} mobileLg={{ col: 6 }} className='graphics-best-bets-link-wrapper'>
                    <a href={link.url}>{parse(link.title)}</a>
                  </Grid>
                );
              })}
            </Grid>
          )}
        </Grid>
      </Grid>
    </GridContainer>
  );
};
