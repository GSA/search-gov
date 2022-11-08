import React from "react"
import PropTypes from "prop-types"

import { GovBanner } from '@trussworks/react-uswds';
// import 'uswds.css';
import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

//import '../../../node_modules/@trussworks/react-uswds/lib/uswds.css';

class HelloWorld extends React.Component {
  render () {
    return (
      <React.Fragment>
        <GovBanner aria-label="Official government website" />
        Greeting: {this.props.greeting}
      </React.Fragment>
    );
  }
}

HelloWorld.propTypes = {
  greeting: PropTypes.string
};
export default HelloWorld
