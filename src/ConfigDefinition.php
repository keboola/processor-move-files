<?php

namespace Keboola\Processor\MoveFiles;

use Symfony\Component\Config\Definition\Builder\TreeBuilder;
use Symfony\Component\Config\Definition\ConfigurationInterface;

class ConfigDefinition implements ConfigurationInterface
{
    public function getConfigTreeBuilder()
    {
        $treeBuilder = new TreeBuilder();
        $rootNode = $treeBuilder->root("parameters");

        $rootNode
            ->children()
                ->enumNode("direction")
                    ->isRequired()
                    ->values(["tables", "files"])
                ->end()
                ->booleanNode("addCsvSuffix")
                    ->defaultFalse()
                ->end()
                ->scalarNode("folder")
                    ->defaultValue('')
                ->end()
                ->booleanNode("createEmptyFolder")
                    ->defaultFalse()
                ->end()
            ->end()
        ;
        return $treeBuilder;
    }
}
