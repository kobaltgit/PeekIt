import Prism from './prism-init';

// 1. Fundamental Base Grammars (Must load first)
import 'prismjs/components/prism-clike.js';
import 'prismjs/components/prism-markup.js';
import 'prismjs/components/prism-markup-templating.js'; // Critical dependency for PHP & templates

// 2. Web & Scripting
import 'prismjs/components/prism-javascript.js';
import 'prismjs/components/prism-typescript.js';
import 'prismjs/components/prism-python.js';
import 'prismjs/components/prism-rust.js';

// 3. Systems, JVM & Mobile
import 'prismjs/components/prism-c.js';
import 'prismjs/components/prism-cpp.js';
import 'prismjs/components/prism-csharp.js';
import 'prismjs/components/prism-go.js';
import 'prismjs/components/prism-java.js';
import 'prismjs/components/prism-kotlin.js';
import 'prismjs/components/prism-swift.js';
import 'prismjs/components/prism-dart.js';
import 'prismjs/components/prism-scala.js';
import 'prismjs/components/prism-groovy.js';
import 'prismjs/components/prism-zig.js';

// 4. Data, Config & Query
import 'prismjs/components/prism-json.js';
import 'prismjs/components/prism-yaml.js';
import 'prismjs/components/prism-toml.js';
import 'prismjs/components/prism-ini.js';
import 'prismjs/components/prism-properties.js';
import 'prismjs/components/prism-sql.js';
import 'prismjs/components/prism-protobuf.js';
import 'prismjs/components/prism-graphql.js';

// 5. Shell & Scripting
import 'prismjs/components/prism-bash.js';
import 'prismjs/components/prism-batch.js';
import 'prismjs/components/prism-powershell.js';
import 'prismjs/components/prism-lua.js';
import 'prismjs/components/prism-php.js';
import 'prismjs/components/prism-ruby.js';
import 'prismjs/components/prism-perl.js';
import 'prismjs/components/prism-r.js';

// 6. Markup & Styles
import 'prismjs/components/prism-css.js';
import 'prismjs/components/prism-scss.js';
import 'prismjs/components/prism-less.js';
import 'prismjs/components/prism-markdown.js';

// 7. DevOps & Tools
import 'prismjs/components/prism-cmake.js';
import 'prismjs/components/prism-docker.js';
import 'prismjs/components/prism-diff.js';

export async function loadAllLanguages(): Promise<void> {
  // Synchronously preloaded at module evaluation
}

export default Prism;
