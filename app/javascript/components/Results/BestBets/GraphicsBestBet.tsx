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
    const order = [];
    for (let index = 0; index < links.length; index += 1) {
      order.push((index % 2 === 0) ? index / 2 : (links.length + index) / 2);
    }

    const reorderedLinks = [];
    for (let index = 0; index < order.length; index += 1) {
      reorderedLinks.push(links[order[index]]);
    }
    return reorderedLinks;
  };

  return (
    <GridContainer className='result search-result-item graphics-best-bets featured-collection'>
      <Grid row gap="md">
        {imageUrl && (
          <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
            <img src={imageUrl} alt={imageAltText && imageAltText} className="result-image"/>
          </Grid>
        )}
        <Grid col={true} className='result-meta-data'>
          <div className='graphics-best-bets-title'>
            {titleUrl ? (
              <a href={titleUrl}>{parse(title)}</a>) : (parse(title)
            )}
          </div>
          {links && links.length > 0 && (
            <Grid row gap="md">
              {sortedLinks(links).map((link, index) => {
                return (
                  <Grid key={index} mobileLg={{ col: (index as number) % 2 === 0 ? 7 : 5 }} className='graphics-best-bets-link-wrapper'>
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
